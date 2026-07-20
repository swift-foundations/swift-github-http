//
//  URLRequest.Handler.GitHub Tests.swift
//  swift-github-live
//
//  Regression tests for F-003: throttle-acquisition failure path must be
//  bounded, floor-delayed, and surface a typed rate-limited error.
//

import Dependencies
import Dependencies_Test_Support
import Foundation
import GitHub_Live_Shared
import Testing

extension URLRequest.Handler.GitHub {
    @Suite("Unit", .dependency(\.context, .test))
    struct Unit {
        @Test("Acquisition failure path throws a typed rate-limited error after a bounded number of attempts")
        func acquisitionFailureIsBoundedAndTyped() async throws {
            // A limiter with a single slot in a 60-second window: the first
            // acquire consumes the slot, every subsequent acquire is denied.
            let client = ThrottledClient<String>(
                rateLimiter: RateLimiter<String>(
                    windows: [.seconds(60, maxAttempts: 1)]
                )
            )
            _ = await client.acquire("token")

            // Pre-fix this looped/recursed unboundedly (an immediate test clock
            // makes every sleep instant, so an unbounded loop spins forever).
            // Post-fix it must give up after `maxAttempts` with a typed error.
            await #expect(throws: URLRequest.Handler.GitHub.Error.rateLimited(attempts: 5)) {
                _ = try await URLRequest.Handler.GitHub.acquireThrottledSlot(
                    "token",
                    client: client,
                    maxAttempts: 5
                )
            }
        }

        @Test("Acquisition delay enforces a minimum floor when no wait hint is available")
        func acquisitionDelayFloorsWithoutHint() {
            let floor = URLRequest.Handler.GitHub.minimumAcquisitionDelay
            #expect(floor > 0)

            // No hint at all: pre-fix this path retried with zero delay.
            #expect(
                URLRequest.Handler.GitHub.acquisitionDelay(
                    retryAfter: nil,
                    nextAllowedAttemptWait: nil
                ) >= floor
            )

            // A non-positive hint (next allowed attempt already in the past)
            // must also be floored, never zero.
            #expect(
                URLRequest.Handler.GitHub.acquisitionDelay(
                    retryAfter: nil,
                    nextAllowedAttemptWait: -3
                ) >= floor
            )

            // A positive hint is jittered but stays within [floor, cap].
            let delay = URLRequest.Handler.GitHub.acquisitionDelay(
                retryAfter: 120,
                nextAllowedAttemptWait: nil
            )
            #expect(delay >= floor)
            #expect(delay <= URLRequest.Handler.GitHub.maximumAcquisitionDelay)
        }

        @Test("Acquisition loop honors task cancellation instead of spinning")
        func acquisitionHonorsCancellation() async throws {
            let client = ThrottledClient<String>(
                rateLimiter: RateLimiter<String>(
                    windows: [.seconds(60, maxAttempts: 1)]
                )
            )
            _ = await client.acquire("token")

            let task = Task {
                _ = try await URLRequest.Handler.GitHub.acquireThrottledSlot(
                    "token",
                    client: client,
                    maxAttempts: .max
                )
            }
            task.cancel()

            await #expect(throws: CancellationError.self) {
                try await task.value
            }
        }
    }
}
