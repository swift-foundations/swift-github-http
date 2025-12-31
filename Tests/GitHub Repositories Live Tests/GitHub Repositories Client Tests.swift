//
//  GitHub Repositories Client Tests.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import GitHub_Repositories_Live
import GitHub_Repositories_Types
import GitHub_Types_Shared
import Testing

@Suite(
    "GitHub Repositories Client Tests",
    .dependency(\.context, .live),
    .dependency(\.envVars, .development),
    .serialized
)
struct GitHubRepositoriesClientTests {
    @Test("Should successfully list repositories for authenticated user")
    func testListRepositories() async throws {
        @Dependency(GitHub.Repositories.self) var repositories

        let response = try await repositories.client.list()
        print(response)
        #expect(!response.isEmpty)

        let firstRepo = response[0]
        #expect(!firstRepo.name.isEmpty)
        #expect(!firstRepo.fullName.isEmpty)
        #expect(firstRepo.owner != nil)
    }

    @Test("Should successfully get a specific repository")
    func testGetRepository() async throws {
        @Dependency(GitHub.Repositories.self) var repositories
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        let repository = try await repositories.client.get(owner, repo)

        #expect(repository.name == repo)
        #expect(repository.owner.login == owner)
        #expect(!repository.fullName.isEmpty)
        #expect(repository.id > 0)
    }

    @Test("Should successfully create a repository")
    func testCreateRepository() async throws {
        @Dependency(GitHub.Repositories.self) var repositories

        let testRepoName = "test-repo-\(Int.random(in: 1000...9999))"

        let request = GitHub.Repositories.Create.Request(
            name: testRepoName,
            description: "Test repository created by swift-github-live tests",
            private: true,
            hasIssues: false,
            hasProjects: false,
            hasWiki: false,
            autoInit: true
        )

        let repository = try await repositories.client.create(request)

        #expect(repository.name == testRepoName)
        #expect(repository.description == request.description)
        #expect(repository.private == true)

        // Clean up - delete the test repository
        try await repositories.client.delete(repository.owner.login, repository.name)
    }

    @Test("Should successfully update a repository")
    func testUpdateRepository() async throws {
        @Dependency(GitHub.Repositories.self) var repositories
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        let originalRepo = try await repositories.client.get(owner, repo)

        let updateRequest = GitHub.Repositories.Update.Request(
            description: "Updated description - \(Date().timeIntervalSince1970)",
            hasIssues: originalRepo.hasIssues,
            hasProjects: originalRepo.hasProjects,
            hasWiki: originalRepo.hasWiki
        )

        let updatedRepo = try await repositories.client.update(owner, repo, updateRequest)

        #expect(updatedRepo.description == updateRequest.description)
        #expect(updatedRepo.name == repo)

        // Restore original description
        let restoreRequest = GitHub.Repositories.Update.Request(
            description: originalRepo.description,
            hasIssues: originalRepo.hasIssues,
            hasProjects: originalRepo.hasProjects,
            hasWiki: originalRepo.hasWiki
        )
        _ = try? await repositories.client.update(owner, repo, restoreRequest)
    }

    @Test("Should handle repository not found error")
    func testGetNonExistentRepository() async throws {
        @Dependency(GitHub.Repositories.self) var repositories
        @Dependency(\.envVars.githubTestOwner) var owner

        do {
            _ = try await repositories.client.get(owner, "non-existent-repo-99999")
            Issue.record("Expected error for non-existent repository")
        } catch {
            // Expected error
            #expect(error != nil)
        }
    }
}
