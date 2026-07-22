// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-github-http",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "GitHub HTTP",
            targets: ["GitHub HTTP"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-github.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-json.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3986.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-8288.git", branch: "main"),
        .package(
            url: "https://github.com/swift-standards/swift-github-standard.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-standards/swift-http-standard.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "GitHub HTTP",
            dependencies: [
                .product(name: "GitHub", package: "swift-github"),
                .product(name: "GitHub Standard", package: "swift-github-standard"),
                .product(name: "HTTP Standard", package: "swift-http-standard"),
                .product(name: "JSON", package: "swift-json"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "RFC 8288", package: "swift-rfc-8288"),
            ]
        ),
        .testTarget(
            name: "GitHub HTTP Tests",
            dependencies: ["GitHub HTTP"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
