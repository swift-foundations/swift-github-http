//
//  EnvironmentVariables+Testing.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import Foundation
import ServerFoundationEnvVars

// MARK: - Test Environment Variables

extension EnvironmentVariables {
    // Test repository configuration
    public var githubTestOwner: String {
        get { self["GITHUB_TEST_OWNER"] ?? "octocat" }
        set { self["GITHUB_TEST_OWNER"] = newValue }
    }

    public var githubTestRepo: String {
        get { self["GITHUB_TEST_REPO"] ?? "Hello-World" }
        set { self["GITHUB_TEST_REPO"] = newValue }
    }
}

// MARK: - Development Environment

extension EnvironmentVariables {
    /// Development environment configuration for testing
    /// Loads from .env file in project root, falls back to system environment in CI
    package static var development: Self {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // GitHub Live Shared
            .deletingLastPathComponent()  // Sources
            .deletingLastPathComponent()  // swift-github-live

        // Gracefully fall back to system environment if .env file doesn't exist (e.g., in CI)
        return
            (try? Self.live(
                environmentConfiguration: EnvironmentConfiguration.projectRoot(
                    projectRoot,
                    environment: "development"
                )
            ))
            ?? (try! Self.live())
    }
}

// MARK: - Context for Testing

extension Dependency.Values {
    package struct Context: Sendable {
        enum ContextType: Sendable {
            case live
            case test
        }

        let type: ContextType

        package static let live = Context(type: .live)
        package static let test = Context(type: .test)
    }

    package var context: Context {
        get { self[ContextKey.self] }
        set { self[ContextKey.self] = newValue }
    }

    private enum ContextKey: Dependency.Key {
        static let liveValue = Context.test
        static let testValue = Context.test
    }
}
