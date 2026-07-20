//
//  URLRequest.Handler.GitHub.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import Clocks_Dependencies
import Dependencies
import Foundation
import Throttling_Dependencies
import URLRequestHandler

// Throttling members ride Throttling_Dependencies (W3).

extension URLRequest.Handler {
    public enum GitHub {}
}

/// Dependency key for GitHub throttled client that uses per-token rate limiting
struct GitHubThrottledClientKey: Dependency.Key {
    static let liveValue = ThrottledClient<String>(
        rateLimiter: RateLimiter<String>(
            windows: [
                .seconds(1, maxAttempts: 100),  // Prevent bursts
                .minutes(1, maxAttempts: 200),  // Smooth sustained rate
                .hours(1, maxAttempts: 5000),  // Stay well under GitHub's 5000/hour limit
            ],
            backoffMultiplier: 2.0
        ),
        pacer: RequestPacer<String>(
            targetRate: 25.0  // 25 requests per second with smooth pacing
        )
    )

    static let testValue = ThrottledClient<String>(
        rateLimiter: RateLimiter<String>(
            windows: [
                .seconds(1, maxAttempts: 5),  // Lower rate for testing
                .minutes(1, maxAttempts: 50),
                .hours(1, maxAttempts: 1000),
            ],
            backoffMultiplier: 2.0
        ),
        pacer: RequestPacer<String>(
            targetRate: 5.0
        )
    )
}

extension Dependency.Values {
    var githubThrottledClient: ThrottledClient<String> {
        get { self[GitHubThrottledClientKey.self] }
        set { self[GitHubThrottledClientKey.self] = newValue }
    }
}

extension URLRequest.Handler.GitHub: Dependency.Key {

    public static var liveValue: URLRequest.Handler { Self.default() }

    public static var testValue: URLRequest.Handler { Self.default() }

    /// Default handler configuration shared between live and test values
    public static func `default`() -> URLRequest.Handler {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return withDependencies {
            $0.defaultSession = { request in
                try await performRateLimitedRequest(request)
            }
        } operation: {
            return .init(
                debug: false,
                decoder: decoder
            )
        }
    }

    private static func performRateLimitedRequest(
        _ request: URLRequest,
        retryCount: Int = 0,
        maxRetries: Int = 5
    ) async throws -> (Data, URLResponse) {
        @Dependency(\.clock) var clock
        @Dependency(\.githubThrottledClient) var throttledClient

        // Extract token from Authorization header for per-token rate limiting
        let rateLimitKey = extractToken(from: request) ?? "anonymous"

        // Use ThrottledClient to check both rate limits and pacing.
        // Acquisition is bounded: it waits (with a floor delay and jitter)
        // between attempts and throws a typed rate-limited error once the
        // attempt bound is exceeded, instead of recursing unboundedly.
        let acquisitionResult = try await acquireThrottledSlot(
            rateLimitKey,
            client: throttledClient,
            maxAttempts: maxRetries
        )

        // Wait for the scheduled time to maintain proper pacing
        try await acquisitionResult.waitUntilReady()

        // Perform the actual request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Check for rate limit response
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 403 || httpResponse.statusCode == 429 {
                    // Check GitHub rate limit headers
                    let remaining =
                        httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining")
                        .flatMap(Int.init) ?? 0

                    if remaining == 0 || httpResponse.statusCode == 429 {
                        // We've hit the rate limit
                        await throttledClient.recordFailure(rateLimitKey)

                        // Check if we've exceeded max retries
                        guard retryCount < maxRetries else {
                            throw URLError(
                                .dataNotAllowed,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "GitHub rate limit exceeded after \(maxRetries) retries"
                                ]
                            )
                        }

                        // Get reset time from headers
                        let resetTime = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Reset")
                            .flatMap(Double.init)
                            .map { Date(timeIntervalSince1970: $0) }

                        let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                            .flatMap(Double.init)

                        // Calculate wait time
                        let waitTime: TimeInterval
                        if let retryAfter = retryAfter {
                            waitTime = retryAfter
                        } else if let resetTime = resetTime {
                            waitTime = max(1, resetTime.timeIntervalSinceNow)
                        } else {
                            // Exponential backoff if no headers available
                            waitTime = min(pow(2.0, Double(retryCount)) * 2, 60)
                        }

                        // Wait and retry with jitter
                        let jitteredDelay = addJitter(to: waitTime)
                        let waitDuration = Duration.seconds(min(jitteredDelay, 300))  // Cap at 5 minutes
                        try await clock.sleep(for: waitDuration)

                        return try await performRateLimitedRequest(
                            request,
                            retryCount: retryCount + 1,
                            maxRetries: maxRetries
                        )
                    }
                } else if (200..<300).contains(httpResponse.statusCode) {
                    // Successful request
                    await throttledClient.recordSuccess(rateLimitKey)
                }
            }

            return (data, response)
        } catch {
            // Record failure for network errors
            await throttledClient.recordFailure(rateLimitKey)
            throw error
        }
    }

    /// The minimum delay between throttle-acquisition attempts.
    ///
    /// Applied when the throttled client provides no wait hint (or a
    /// non-positive one), so the retry loop can never spin with zero delay.
    package static let minimumAcquisitionDelay: TimeInterval = 0.1

    /// The maximum delay between throttle-acquisition attempts.
    package static let maximumAcquisitionDelay: TimeInterval = 60

    /// Computes the delay before the next throttle-acquisition attempt.
    ///
    /// - Parameters:
    ///   - retryAfter: The client's retry-after hint, if any.
    ///   - nextAllowedAttemptWait: Seconds until the rate limiter's next
    ///     allowed attempt, if known.
    /// - Returns: A jittered delay clamped to
    ///   `minimumAcquisitionDelay...maximumAcquisitionDelay`.
    package static func acquisitionDelay(
        retryAfter: TimeInterval?,
        nextAllowedAttemptWait: TimeInterval?
    ) -> TimeInterval {
        let hint = retryAfter ?? nextAllowedAttemptWait
        guard let hint, hint > 0 else { return minimumAcquisitionDelay }
        return max(addJitter(to: min(hint, maximumAcquisitionDelay)), minimumAcquisitionDelay)
    }

    /// Acquires a throttle slot, retrying a bounded number of times.
    ///
    /// Honors task cancellation between attempts and enforces a minimum
    /// floor delay so the loop cannot spin with zero delay.
    ///
    /// - Throws: `URLRequest.Handler.GitHub.Error.rateLimited` once
    ///   `maxAttempts` denied acquisitions have occurred, or
    ///   `CancellationError` if the task is cancelled.
    package static func acquireThrottledSlot(
        _ key: String,
        client: ThrottledClient<String>,
        maxAttempts: Int
    ) async throws -> ThrottledClient<String>.AcquisitionResult {
        @Dependency(\.clock) var clock

        var attempts = 0
        while true {
            try Task.checkCancellation()

            let result = await client.acquire(key)
            if result.canProceed { return result }

            attempts += 1
            guard attempts < maxAttempts else {
                throw Error.rateLimited(attempts: attempts)
            }

            let delay = acquisitionDelay(
                retryAfter: result.retryAfter,
                nextAllowedAttemptWait: result.rateLimitResult?.nextAllowedAttempt?
                    .timeIntervalSinceNow
            )
            try await clock.sleep(for: .seconds(delay))
        }
    }

    /// Extracts the token from the Authorization header for per-token rate limiting
    private static func extractToken(from request: URLRequest) -> String? {
        guard let authHeader = request.value(forHTTPHeaderField: "Authorization") else {
            return nil
        }

        // Handle both "token xxx" and "Bearer xxx" formats
        if authHeader.hasPrefix("token ") {
            return String(authHeader.dropFirst(6))
        } else if authHeader.hasPrefix("Bearer ") {
            return String(authHeader.dropFirst(7))
        }

        return authHeader
    }

    /// Adds jitter to a delay value to prevent thundering herd problem
    private static func addJitter(to baseDelay: TimeInterval) -> TimeInterval {
        // Full jitter: random value between 0 and baseDelay
        Double.random(in: 0...baseDelay)
    }
}
