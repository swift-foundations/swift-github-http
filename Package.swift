// swift-tools-version: 6.3.1

import PackageDescription

extension String {
    static let githubLive: Self = "GitHub Live"
    static let githubTrafficLive: Self = "GitHub Traffic Live"
    static let githubRepositoriesLive: Self = "GitHub Repositories Live"
    static let githubStargazersLive: Self = "GitHub Stargazers Live"
    static let githubOAuthLive: Self = "GitHub OAuth Live"
    static let githubCollaboratorsLive: Self = "GitHub Collaborators Live"
    static let githubLiveShared: Self = "GitHub Live Shared"
}

extension Target.Dependency {
    static var githubLive: Self { .target(name: .githubLive) }
    static var githubTrafficLive: Self { .target(name: .githubTrafficLive) }
    static var githubRepositoriesLive: Self { .target(name: .githubRepositoriesLive) }
    static var githubStargazersLive: Self { .target(name: .githubStargazersLive) }
    static var githubOAuthLive: Self { .target(name: .githubOAuthLive) }
    static var githubCollaboratorsLive: Self { .target(name: .githubCollaboratorsLive) }
    static var githubLiveShared: Self { .target(name: .githubLiveShared) }
}

extension Target.Dependency {
    static var githubTypes: Self { .product(name: "GitHub Types", package: "swift-github-types") }
    static var githubTrafficTypes: Self {
        .product(name: "GitHub Traffic Types", package: "swift-github-types")
    }
    static var githubRepositoriesTypes: Self {
        .product(name: "GitHub Repositories Types", package: "swift-github-types")
    }
    static var githubStargazersTypes: Self {
        .product(name: "GitHub Stargazers Types", package: "swift-github-types")
    }
    static var githubOAuthTypes: Self {
        .product(name: "GitHub OAuth Types", package: "swift-github-types")
    }
    static var githubCollaboratorsTypes: Self {
        .product(name: "GitHub Collaborators Types", package: "swift-github-types")
    }
    static var githubTypesShared: Self {
        .product(name: "GitHub Types Shared", package: "swift-github-types")
    }

    static var serverFoundation: Self {
        .product(name: "ServerFoundation", package: "swift-server-foundation")
    }
    static var authenticating: Self {
        .product(name: "Authenticating", package: "swift-authenticating")
    }
    static var dependenciesTestSupport: Self {
        .product(name: "Dependencies Test Support", package: "swift-dependencies")
    }
}

let package = Package(
    name: "swift-github-live",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
    ],
    products: [
        .library(name: .githubLive, targets: [.githubLive]),
        .library(name: .githubTrafficLive, targets: [.githubTrafficLive]),
        .library(name: .githubRepositoriesLive, targets: [.githubRepositoriesLive]),
        .library(name: .githubStargazersLive, targets: [.githubStargazersLive]),
        .library(name: .githubOAuthLive, targets: [.githubOAuthLive]),
        .library(name: .githubCollaboratorsLive, targets: [.githubCollaboratorsLive]),
        .library(name: .githubLiveShared, targets: [.githubLiveShared]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-github-types.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-server-foundation.git", branch: "main"),
        .package(url: "https://github.com/coenttb/swift-authenticating", from: "0.0.2"),
        .package(url: "https://github.com/swift-foundations/swift-dependencies.git", branch: "main"),
    ],
    targets: [
        .target(
            name: .githubLiveShared,
            dependencies: [
                .serverFoundation,
                .authenticating,
                .githubTypesShared,
            ]
        ),
        .target(
            name: .githubLive,
            dependencies: [
                .serverFoundation,
                .githubLiveShared,
                .githubTypes,
                .githubTrafficLive,
                .githubRepositoriesLive,
                .githubStargazersLive,
                .githubOAuthLive,
                .githubCollaboratorsLive,
            ]
        ),
        .target(
            name: .githubTrafficLive,
            dependencies: [
                .serverFoundation,
                .githubLiveShared,
                .githubTrafficTypes,
            ]
        ),
        .target(
            name: .githubRepositoriesLive,
            dependencies: [
                .serverFoundation,
                .githubLiveShared,
                .githubRepositoriesTypes,
            ]
        ),
        .target(
            name: .githubStargazersLive,
            dependencies: [
                .serverFoundation,
                .githubLiveShared,
                .githubStargazersTypes,
            ]
        ),
        .target(
            name: .githubOAuthLive,
            dependencies: [
                .serverFoundation,
                .githubLiveShared,
                .githubOAuthTypes,
            ]
        ),
        .target(
            name: .githubCollaboratorsLive,
            dependencies: [
                .serverFoundation,
                .githubLiveShared,
                .githubCollaboratorsTypes,
            ]
        ),
        .testTarget(
            name: "GitHub Live Tests",
            dependencies: [
                .githubLive,
                .dependenciesTestSupport,
            ]
        ),
        .testTarget(
            name: "GitHub Traffic Live Tests",
            dependencies: [
                .githubTrafficLive,
                .dependenciesTestSupport,
            ]
        ),
        .testTarget(
            name: "GitHub Repositories Live Tests",
            dependencies: [
                .githubRepositoriesLive,
                .dependenciesTestSupport,
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
