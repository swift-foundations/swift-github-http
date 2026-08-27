import GitHub_HTTP
import Testing

extension GitHub.HTTP {
    @Suite("GitHub.HTTP.Content.Unit")
    struct Content {
        @Test("Package.swift content maps through the provider endpoint")
        func present() async throws {
            let client = GitHub.HTTP.Client<Failure, Never>(
                agent: .init(rawValue: "workspace-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(Failure) in
                    #expect(request.method == .get)
                    #expect(
                        // swift-linter:disable:next raw value access
                        // REASON: test asserts the raw wire string of the request target
                        request.target.rawValue
                            == "https://api.github.com/repos/swift-compositions/swift-github/contents/Package.swift"
                    )
                    #expect(
                        // swift-linter:disable:next raw value access
                        // REASON: test asserts the raw wire string of the Accept header
                        request.headers.first("Accept")?.rawValue == "application/vnd.github+json"
                    )
                    // swift-linter:disable:next raw value access
                    // REASON: test asserts the raw wire string of the User-Agent header
                    #expect(request.headers.first("User-Agent")?.rawValue == "workspace-tests")
                    // swift-linter:disable:next raw value access
                    // REASON: test asserts the raw wire string of the API-version header
                    #expect(request.headers.first("X-GitHub-Api-Version")?.rawValue == "2026-03-10")
                    #expect(request.headers.first("Authorization") == nil)
                    return .init(status: .ok, body: Self.bytes(#"{"type":"file"}"#))
                },
                pagination: .none
            )

            #expect(
                try await client.content(authentication: .none).get(try Self.request())?.kind
                    == .file
            )
        }

        @Test("A 404 means the package manifest is absent")
        func absent() async throws {
            let client = GitHub.HTTP.Client<Failure, Never>(
                agent: .init(rawValue: "workspace-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { _ async throws(Failure) in .init(status: .notFound) },
                pagination: .none
            )

            #expect(
                try await client.content(authentication: .none).get(try Self.request()) == nil
            )
        }

        @Test("Unknown content kinds remain typed JSON failures")
        func kind() async throws {
            let client = GitHub.HTTP.Client<Failure, Never>(
                agent: .init(rawValue: "workspace-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { _ async throws(Failure) in
                    .init(status: .ok, body: Self.bytes(#"{"type":"unknown"}"#))
                },
                pagination: .none
            )

            await #expect(throws: GitHub.HTTP.Error<Failure, Never>.self) {
                try await client.content(authentication: .none).get(try Self.request())
            }
        }

        private static func request() throws(Failure) -> GitHub.Repository.Content.Request {
            guard let path = GitHub.Repository.Content.Path(segments: ["Package.swift"])
            else { throw .unexpected }
            return .init(
                organization: .init("swift-compositions"),
                repository: .init("swift-github"),
                path: path
            )
        }

        private static func bytes(_ string: String) -> [Byte] {
            string.utf8.map(Byte.init)
        }

        enum Failure: Swift.Error, Sendable {
            case unexpected
        }
    }
}
