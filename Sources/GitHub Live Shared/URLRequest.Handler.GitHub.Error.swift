//
//  URLRequest.Handler.GitHub.Error.swift
//  swift-github-live
//
//  Typed errors for the GitHub request handler.
//

import Foundation
import URLRequestHandler

extension URLRequest.Handler.GitHub {
    /// Errors surfaced by the GitHub request handler's throttling layer.
    public enum Error: Swift.Error, Equatable, Sendable {
        /// Local throttle acquisition kept failing after the bounded number
        /// of attempts.
        case rateLimited(attempts: Int)
    }
}

extension URLRequest.Handler.GitHub.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .rateLimited(let attempts):
            return "GitHub request throttled: rate limit acquisition failed after \(attempts) attempts"
        }
    }
}
