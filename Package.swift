// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-github-http",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "GitHub HTTP",
            targets: ["GitHub HTTP"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-compositions/swift-github.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-compositions/swift-html-form-coder.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-compositions/swift-http-router.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-compositions/swift-json.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3986.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3986-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-6531.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-8288.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-9110.git", branch: "main"),
        .package(
            url: "https://github.com/swift-standards/swift-github-standard.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-standards/swift-http.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-standards/swift-html-standard.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "GitHub HTTP",
            dependencies: [
                .product(name: "GitHub", package: "swift-github"),
                .product(name: "GitHub Standard", package: "swift-github-standard"),
                .product(name: "HTML Form Coder", package: "swift-html-form-coder"),
                .product(name: "HTML Standard", package: "swift-html-standard"),
                .product(name: "HTTP Router", package: "swift-http-router"),
                .product(name: "HTTP", package: "swift-http"),
                .product(name: "JSON", package: "swift-json"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "RFC 3986 Coder", package: "swift-rfc-3986-coder"),
                .product(name: "RFC 6531", package: "swift-rfc-6531"),
                .product(name: "RFC 8288", package: "swift-rfc-8288"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
            ]
        ),
        .testTarget(
            name: "GitHub HTTP Tests",
            dependencies: ["GitHub HTTP"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
