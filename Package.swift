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
        .package(path: "../swift-github"),
        .package(path: "../swift-json"),
        .package(path: "../../swift-ietf/swift-rfc-3986"),
        .package(path: "../../swift-standards/swift-github-types"),
        .package(path: "../../swift-standards/swift-http-standard"),
    ],
    targets: [
        .target(
            name: "GitHub HTTP",
            dependencies: [
                .product(name: "GitHub", package: "swift-github"),
                .product(name: "GitHub Standard", package: "swift-github-types"),
                .product(name: "HTTP Standard", package: "swift-http-standard"),
                .product(name: "JSON", package: "swift-json"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
            ]
        ),
        .testTarget(
            name: "GitHub HTTP Tests",
            dependencies: ["GitHub HTTP"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
