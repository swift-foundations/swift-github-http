//
//  GitHub.Repositories.Client.live.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import GitHub_Live_Shared
import GitHub_Repositories_Types

extension GitHub.Repositories.Client {
    public static func live(
        makeRequest: @escaping @Sendable (_ route: GitHub.Repositories.API) throws -> URLRequest
    ) -> Self {
        @Dependency(URLRequest.Handler.GitHub.self) var handleRequest

        return Self(
            // https://docs.github.com/en/rest/repos/repos#list-repositories-for-the-authenticated-user
            list: { request in
                try await handleRequest(
                    for: makeRequest(.list(request: request)),
                    decodingTo: GitHub.Repositories.List.Response.self
                )
            },

            // https://docs.github.com/en/rest/repos/repos#get-a-repository
            get: { owner, repo in
                try await handleRequest(
                    for: makeRequest(.get(owner: owner, repo: repo)),
                    decodingTo: GitHub.Repository.self
                )
            },

            // https://docs.github.com/en/rest/repos/repos#create-a-repository-for-the-authenticated-user
            create: { request in
                try await handleRequest(
                    for: makeRequest(.create(request: request)),
                    decodingTo: GitHub.Repository.self
                )
            },

            // https://docs.github.com/en/rest/repos/repos#update-a-repository
            update: { owner, repo, request in
                try await handleRequest(
                    for: makeRequest(.update(owner: owner, repo: repo, request: request)),
                    decodingTo: GitHub.Repository.self
                )
            },

            // https://docs.github.com/en/rest/repos/repos#delete-a-repository
            delete: { owner, repo in
                try await handleRequest(
                    for: makeRequest(.delete(owner: owner, repo: repo)),
                    decodingTo: GitHub.Repositories.Delete.Response.self
                )
            }
        )
    }
}

extension GitHub.Repositories {
    public typealias Authenticated = GitHub_Live_Shared.Authenticated<
        GitHub.Repositories.API,
        GitHub.Repositories.API.Router,
        GitHub.Repositories.Client
    >
}

extension GitHub.Repositories: @retroactive Dependency.Key {
    public static var liveValue: GitHub.Repositories.Authenticated {
        @Dependency(\.envVars.githubBaseUrl) var baseUrl
        @Dependency(\.envVars.githubToken) var token

        return try! GitHub.Repositories.Authenticated(
            baseURL: baseUrl,
            token: token
        ) { .live(makeRequest: $0) }
    }

    public static let testValue: GitHub.Repositories.Authenticated = liveValue
}

extension GitHub.Repositories.API.Router: @retroactive Dependency.Key {
    public static let liveValue: Self = .init()
    public static let testValue: Self = .init()
}
