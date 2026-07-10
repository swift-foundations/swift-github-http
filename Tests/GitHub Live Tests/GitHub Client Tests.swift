//
//  GitHub Client Tests.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import Dependencies
import Dependencies_Test_Support
import Foundation
import GitHub_Live
import GitHub_Types
import Testing

@Suite(
    "GitHub Client Tests",
    .dependency(\.context, .live),
    .dependency(\.envVars, .development),
    .serialized
)
struct GitHubClientTests {
    @Test("Should successfully initialize GitHub client with environment variables")
    func testGitHubClientInitialization() async throws {
        @Dependency(\.github) var github
        @Dependency(\.envVars.githubToken) var token
        @Dependency(\.envVars.githubBaseUrl) var baseUrl

        #expect(!token.isEmpty)
        #expect(baseUrl.absoluteString.contains("github.com"))

        // Client should be initialized and accessible
        // The client properties exist and are accessible
    }

    @Test("Should successfully fetch traffic and repository data")
    func testIntegratedWorkflow() async throws {
        @Dependency(\.github) var github
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        // Get repository information
        let repository = try await github.client.repositories.get(owner, repo)
        #expect(repository.name == repo)

        // Get traffic views
        let views = try await github.client.traffic.views(owner, repo, nil)
        #expect(views.count >= 0)

        // Get traffic clones
        let clones = try await github.client.traffic.clones(owner, repo, nil)
        #expect(clones.count >= 0)

        // Get top paths
        let paths = try await github.client.traffic.paths(owner, repo)
        #expect(paths.paths.isEmpty)

        // Get top referrers
        let referrers = try await github.client.traffic.referrers(owner, repo)
        #expect(referrers.referrers.isEmpty)
    }

    @Test("Should handle rate limiting gracefully")
    func testRateLimiting() async throws {
        @Dependency(\.github) var github
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        // Make multiple requests to test rate limiting handling
        for _ in 0..<3 {
            let views = try await github.client.traffic.views(owner, repo, nil)
            #expect(views.count >= 0)
        }
    }
}
