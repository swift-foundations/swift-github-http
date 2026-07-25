# swift-github-http

[![CI](https://github.com/swift-foundations/swift-github-http/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-foundations/swift-github-http/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

HTTP bindings for the typed GitHub operations published by `swift-github`.

## Overview

`swift-github-http` maps canonical GitHub requests and responses to Foundation-free HTTP values. It provides:

- explicit bearer-token authentication at construction sites;
- repository metadata and content operations;
- user and organization repository pagination;
- repository stargazer pagination;
- repository traffic views, clones, paths, and referrers;
- OAuth authorization and token exchange;
- authenticated-user profile and email operations;
- injected HTTP execution for deterministic, credential-free tests.

## Installation

Add the package dependency:

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-foundations/swift-github-http.git",
        from: "0.2.0"
    )
]
```

Then add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "GitHub HTTP", package: "swift-github-http")
    ]
)
```

## Usage

```swift
import GitHub_HTTP

let http = GitHub.HTTP.Client(
    agent: .init(rawValue: "example-service"),
    version: .init(rawValue: "2026-03-10"),
    execute: transport.execute
)

let traffic = http.traffic(authentication: .token(token))
let views = try await traffic.views(
    .init(
        owner: .init(rawValue: "swiftlang"),
        repository: .init(rawValue: "swift")
    )
)
```

## Architecture

`GitHub Standard` owns provider vocabulary and wire-shaped values. `GitHub` owns typed operation clients and bounded traversal. `GitHub HTTP` owns request construction, response decoding, authentication headers, and RFC 8288 pagination witnesses.

Traffic and Stargazers remain separate provider domains: Traffic describes repository analytics aggregates, while Stargazers describes user-attributed starring events.

OAuth authorization and token exchange are exposed at
`client.oauth.authorization` and `client.oauth.token.exchange`. The supporting
Users API operations remain `client.user.authenticated.get` and
`client.user.authenticated.emails.list`. Token exchange uses the canonical HTML
form coder and HTTP body coupling; no configured-live transport is included.

## Testing

All package tests inject an in-memory HTTP execution closure. They make no live API calls and require no credentials.

## Requirements

- Swift 6.3+

## Error Handling

Every operation client throws the package's typed envelope
`GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>`, where `ExecutionFailure`
is the injected transport's failure type and `PaginationFailure` is the RFC 8288
traversal failure type (`Never` for non-paginated operations):

```
GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>
├── .execute(ExecutionFailure)          // injected transport rejected the request
├── .header(HTTP.Header.Field.Error)    // request header construction failed
├── .json(JSON.Error)                   // response body decoding failed
├── .pagination(PaginationFailure)      // RFC 8288 Link traversal failed
├── .path(RFC_3986.URI.Path.Error)      // request path construction failed
├── .query(RFC_3986.URI.Query.Error)    // request query construction failed
├── .scheme(RFC_3986.URI.Scheme.Error)  // request scheme construction failed
└── .status(HTTP.Status)                // GitHub returned a non-success status
```

Because the envelope is a typed throw, a paginated call such as
`stargazers(_:).page(_:)` matches every arm exhaustively:

```swift
do {
    let page = try await http.stargazers(authentication: .token(token)).page(
        .init(
            owner: .init(rawValue: "swiftlang"),
            repository: .init(rawValue: "swift"),
            page: .first,
            size: .maximum
        )
    )
    _ = page.response.stargazers
} catch .execute(let failure) {
    // injected transport rejected the request
} catch .header(let error) {
    // request header construction failed
} catch .json(let error) {
    // response body decoding failed
} catch .pagination(let error) {
    // RFC 8288 Link traversal failed
} catch .path(let error) {
    // request path construction failed
} catch .query(let error) {
    // request query construction failed
} catch .scheme(let error) {
    // request scheme construction failed
} catch .status(let status) {
    // GitHub returned a non-success HTTP status
}
```

The `.pagination` payload is `GitHub.HTTP.Pagination.Error` (`.link`, `.next`,
`.page`) for the stargazer and repository traversals, and OAuth token exchange
(`client.oauth.token.exchange`) throws `GitHub.HTTP.OAuth.Error`, which wraps this
envelope in its `.http` case alongside a `.provider` case for exchange failures.

## License

This package is licensed under the AGPL 3.0 License. See [LICENSE.md](LICENSE.md) for details.
