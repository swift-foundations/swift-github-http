import GitHub_HTTP
import Testing

extension GitHub.HTTP {
    @Suite("GitHub.HTTP.Content.Unit")
    struct Content {
        @Test("Package.swift content maps through the provider endpoint")
        func present() async throws {
            let client = GitHub.HTTP.Client<Fixture.Failure, Never>(
                agent: .init(rawValue: "workspace-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(Fixture.Failure) in
                    #expect(request.method == .get)
                    #expect(
                        request.target.rawValue
                            == "https://api.github.com/repos/swift-foundations/swift-github/contents/Package.swift"
                    )
                    #expect(
                        request.headers.first("Accept")?.rawValue == "application/vnd.github+json"
                    )
                    #expect(request.headers.first("User-Agent")?.rawValue == "workspace-tests")
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
            let client = GitHub.HTTP.Client<Fixture.Failure, Never>(
                agent: .init(rawValue: "workspace-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { _ async throws(Fixture.Failure) in .init(status: .notFound) },
                pagination: .none
            )

            #expect(
                try await client.content(authentication: .none).get(try Self.request()) == nil
            )
        }

        @Test("Unknown content kinds remain typed JSON failures")
        func kind() async throws {
            let client = GitHub.HTTP.Client<Fixture.Failure, Never>(
                agent: .init(rawValue: "workspace-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { _ async throws(Fixture.Failure) in
                    .init(status: .ok, body: Self.bytes(#"{"type":"unknown"}"#))
                },
                pagination: .none
            )

            await #expect(throws: GitHub.HTTP.Error<Fixture.Failure, Never>.self) {
                try await client.content(authentication: .none).get(try Self.request())
            }
        }

        private static func request() throws(Fixture.Failure) -> GitHub.Repository.Content.Request {
            guard let path = GitHub.Repository.Content.Path(segments: ["Package.swift"])
            else { throw .unexpected }
            return .init(
                organization: .init(rawValue: "swift-foundations"),
                repository: .init(rawValue: "swift-github"),
                path: path
            )
        }

        private static func bytes(_ string: String) -> [Byte] {
            string.utf8.map(Byte.init)
        }

        enum Fixture {
            enum Failure: Swift.Error, Sendable {
                case unexpected
            }
        }
    }
}
