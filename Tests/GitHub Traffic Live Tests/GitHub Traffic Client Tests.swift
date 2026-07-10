//
//  GitHub Traffic Client Tests.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import Dependencies
import Dependencies_Test_Support
import Foundation
import GitHub_Traffic_Live
import GitHub_Traffic_Types
import GitHub_Types_Shared
import Testing

@Suite(
    "GitHub Traffic Client Tests",
    .dependency(\.context, .live),
    .dependency(\.envVars, .development),
    .serialized
)
struct GitHubTrafficClientTests {
    @Test("Should successfully fetch repository views")
    func testGetViews() async throws {
        @Dependency(GitHub.Traffic.self) var traffic
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        let response = try await traffic.client.views(owner, repo, nil)
        print(response)
        #expect(response.count >= 0)
        #expect(response.uniques >= 0)
    }

    @Test("Should successfully fetch repository views with daily breakdown")
    func testGetViewsDaily() async throws {
        @Dependency(GitHub.Traffic.self) var traffic
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        let response = try await traffic.client.views(owner: owner, repo: repo, per: .day)
        print(response)
        #expect(response.count >= 0)
        #expect(response.uniques >= 0)

        let views = response.views
        if !views.isEmpty {
            let firstView = views[0]
            #expect(firstView.count > 0)
            #expect(firstView.uniques >= 0)
        }
    }

    @Test("Should successfully fetch repository clones")
    func testGetClones() async throws {
        @Dependency(GitHub.Traffic.self) var traffic
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        let response = try await traffic.client.clones(owner, repo, nil)
        print(response)
        #expect(response.count >= 0)
        #expect(response.uniques >= 0)
    }

    @Test("Should successfully fetch repository clones with daily breakdown")
    func testGetClonesDaily() async throws {
        @Dependency(GitHub.Traffic.self) var traffic
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        let response = try await traffic.client.clones(owner, repo, .day)
        print(response)
        #expect(response.count >= 0)
        #expect(response.uniques >= 0)

        let clones = response.clones
        if !clones.isEmpty {
            let firstClone = clones[0]
            #expect(firstClone.count > 0)
            #expect(firstClone.uniques >= 0)
        }
    }

    @Test("Should successfully fetch top referral paths")
    func testGetPaths() async throws {
        @Dependency(GitHub.Traffic.self) var traffic
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        let response = try await traffic.client.paths(owner, repo)
        print(response)
        let paths = response.paths
        if !paths.isEmpty {
            let firstPath = paths[0]
            #expect(!firstPath.path.isEmpty)
            #expect(!firstPath.title.isEmpty)
            #expect(firstPath.count > 0)
            #expect(firstPath.uniques >= 0)
        }
    }

    @Test("Should successfully fetch top referrers")
    func testGetReferrers() async throws {
        @Dependency(GitHub.Traffic.self) var traffic
        @Dependency(\.envVars.githubTestOwner) var owner
        @Dependency(\.envVars.githubTestRepo) var repo

        let response = try await traffic.client.referrers(owner, repo)
        print(response)
        let referrers = response.referrers
        if !referrers.isEmpty {
            let firstReferrer = referrers[0]
            #expect(!firstReferrer.referrer.isEmpty)
            #expect(firstReferrer.count > 0)
            #expect(firstReferrer.uniques >= 0)
        }
    }
}
