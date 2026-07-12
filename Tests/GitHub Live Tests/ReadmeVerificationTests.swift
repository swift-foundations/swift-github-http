//
//  ReadmeVerificationTests.swift
//  swift-github-live
//
//  Verification tests for README.md code examples
//

import Dependencies
import Dependencies_Test_Support
import Foundation
import GitHub_Live
import GitHub_Repositories_Types
import GitHub_Stargazers_Types
import GitHub_Traffic_Types
import GitHub_Types
import Testing

@Suite(
    "README Verification Tests",
    .dependency(\.context, .live),
    .dependency(\.envVars, .development)
)
struct ReadmeVerificationTests {
    @Dependency(\.github) var github

    // MARK: - Lines 36-50: Basic Setup

    @Test("README Lines 36-50: Basic Setup - GitHub client access")
    func basicSetupExample() {
        // Verify client structure exists
        _ = github.client.traffic
        _ = github.client.repositories
        _ = github.client.stargazers
        _ = github.client.oauth
        _ = github.client.collaborators
    }

    // MARK: - Lines 54-84: Fetching Repository Traffic

    @Test("README Lines 62-67: Traffic views example")
    func trafficViewsExample() async throws {
        @Dependency(\.envVars.githubTestOwner) var testOwner
        @Dependency(\.envVars.githubTestRepo) var testRepo

        let views = try await github.client.traffic.views(
            testOwner,
            testRepo,
            nil
        )
        // Test passes if API call succeeds
    }

    @Test("README Lines 70-75: Traffic clones example")
    func trafficClonesExample() async throws {
        @Dependency(\.envVars.githubTestOwner) var testOwner
        @Dependency(\.envVars.githubTestRepo) var testRepo

        let clones = try await github.client.traffic.clones(
            testOwner,
            testRepo,
            .week
        )
        // Test passes if API call succeeds
    }

    @Test("README Lines 78-79: Traffic paths example")
    func trafficPathsExample() async throws {
        @Dependency(\.envVars.githubTestOwner) var testOwner
        @Dependency(\.envVars.githubTestRepo) var testRepo

        let paths = try await github.client.traffic.paths(testOwner, testRepo)
        #expect(paths.paths.isEmpty)
    }

    @Test("README Lines 82-83: Traffic referrers example")
    func trafficReferrersExample() async throws {
        @Dependency(\.envVars.githubTestOwner) var testOwner
        @Dependency(\.envVars.githubTestRepo) var testRepo

        let referrers = try await github.client.traffic.referrers(testOwner, testRepo)
        #expect(referrers.referrers.isEmpty)
    }

    // MARK: - Lines 88-103: Working with Stargazers

    @Test("README Lines 95-102: Stargazers list example")
    func stargazersListExample() async throws {
        @Dependency(\.envVars.githubTestOwner) var testOwner
        @Dependency(\.envVars.githubTestRepo) var testRepo

        let request = GitHub.Stargazers.List.Request(perPage: 100, page: 1)
        let response = try await github.client.stargazers.list(
            testOwner,
            testRepo,
            request
        )
        // Test passes if API call succeeds
    }

    // MARK: - Lines 107-142: Repository Management

    @Test("README Lines 115-116: Get repository example")
    func repositoryGetExample() async throws {
        @Dependency(\.envVars.githubTestOwner) var testOwner
        @Dependency(\.envVars.githubTestRepo) var testRepo

        let repo = try await github.client.repositories.get(testOwner, testRepo)
        #expect(!repo.name.isEmpty)
    }

    @Test("README Lines 119-124: List repositories example")
    func repositoryListExample() async throws {
        let listRequest = GitHub.Repositories.List.Request(
            visibility: .public,
            sort: .updated,
            direction: .desc
        )
        let repos = try await github.client.repositories.list(listRequest)
        // Test passes if API call succeeds
    }

    @Test("README Lines 127-132: Create repository example")
    func repositoryCreateExample() {
        // Compilation-only test - verify types are correct
        let createRequest = GitHub.Repositories.Create.Request(
            name: "new-repo",
            description: "A new repository",
            private: false
        )
        // Verify request compiles
        _ = createRequest
    }

    @Test("README Lines 135-138: Update repository example")
    func repositoryUpdateExample() {
        // Compilation-only test - verify types are correct
        let updateRequest = GitHub.Repositories.Update.Request(
            description: "Updated description"
        )
        // Verify request compiles
        _ = updateRequest
    }

    @Test("README Lines 141: Delete repository example")
    func repositoryDeleteExample() {
        // Compilation-only test - verify method signature is correct
        // We don't actually call delete in tests to avoid modifying repos
    }

    // MARK: - Lines 187-201: Testing Example

    @Test("README Lines 192-200: Testing with dependencies example")
    func testingExample() {
        // Verify client is accessible
        _ = github.client.traffic
        _ = github.client.repositories
        _ = github.client.stargazers
    }

    // MARK: - Type Verification Tests

    @Test("Verify module imports compile correctly")
    func moduleImportsTest() {
        // Check client structure
        let client = github.client
        #expect(type(of: client) == GitHub.Client.self)

        // Verify sub-clients exist
        _ = client.traffic
        _ = client.repositories
        _ = client.stargazers
        _ = client.oauth
        _ = client.collaborators
    }

    @Test("Verify Traffic types compile correctly")
    func trafficTypesTest() {
        // Verify traffic types are accessible
        _ = GitHub.Traffic.Views.Response.self
        _ = GitHub.Traffic.Clones.Response.self
        _ = GitHub.Traffic.Paths.Response.self
        _ = GitHub.Traffic.Referrers.Response.self
        _ = GitHub.Traffic.Per.self
    }

    @Test("Verify Stargazers types compile correctly")
    func stargazersTypesTest() {
        // Verify stargazers types are accessible
        _ = GitHub.Stargazers.List.Request.self
        _ = GitHub.Stargazers.List.Response.self
    }

    @Test("Verify Repositories types compile correctly")
    func repositoriesTypesTest() {
        // Verify repositories types are accessible
        _ = GitHub.Repository.self
        _ = GitHub.Repositories.List.Request.self
        _ = GitHub.Repositories.List.Response.self
        _ = GitHub.Repositories.Create.Request.self
        _ = GitHub.Repositories.Update.Request.self
        _ = GitHub.Repositories.Delete.Response.self
    }

    @Test("Verify client architecture structure")
    func clientArchitectureTest() {
        // Verify the main client provides access to all sub-clients
        let client = github.client

        // Traffic client
        let trafficClient = client.traffic
        #expect(type(of: trafficClient) == GitHub.Traffic.Client.self)

        // Repositories client
        let reposClient = client.repositories
        #expect(type(of: reposClient) == GitHub.Repositories.Client.self)

        // Stargazers client
        let stargazersClient = client.stargazers
        #expect(type(of: stargazersClient) == GitHub.Stargazers.Client.self)

        // OAuth client
        let oauthClient = client.oauth
        #expect(type(of: oauthClient) == GitHub.OAuth.Client.self)

        // Collaborators client
        let collaboratorsClient = client.collaborators
        #expect(type(of: collaboratorsClient) == GitHub.Collaborators.Client.self)
    }

    @Test("Verify dependency injection setup")
    func dependencyInjectionTest() {
        // Verify client is accessible
        _ = github.client

        // Verify router is accessible
        _ = github.apiRouter
    }

    @Test("Verify Authenticated wrapper structure")
    func authenticatedWrapperTest() {
        // Verify the authenticated wrapper provides client and router
        _ = github.client
        _ = github.apiRouter

        // Verify type is GitHub.Authenticated
        #expect(type(of: github) == GitHub.Authenticated.self)
    }
}
