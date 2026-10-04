import Byte
import GitHub_HTTP
import HTTP
import HTTP_Router
import RFC_9110
import Testing

extension GitHub.HTTP {
    @Suite("GitHub.HTTP.Client.Unit")
    struct Unit {
        @Test("The product re-exports the HTTP execute surface")
        func exports() {
            let headers = RFC_9110.Message.Headers()
            let request = HTTP.Router.Request(method: .options, target: .asterisk, headers: headers)
            let response = HTTP.Router.Response(status: .ok, headers: headers)

            #expect(request.method == .options)
            #expect(request.target == .asterisk)
            #expect(request.headers.isEmpty)
            #expect(response.status == .ok)
            #expect(response.headers.isEmpty)
        }

        @Test("The adapter maps the provider request and decodes a response page")
        func page() async throws {
            let http = GitHub.HTTP.Client<Fixture.Execution, Fixture.Pagination>(
                agent: .init(rawValue: "swift-institute"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(Fixture.Execution) in
                    #expect(request.method == .get)
                    #expect(
                        // swift-linter:disable:next raw value access
                        // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                        request.target.rawValue
                            == "https://api.github.com/orgs/swiftlang/repos?type=public&per_page=100&page=1"
                    )
                    #expect(
                        // swift-linter:disable:next raw value access
                        // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                        request.headers.first("Accept")?.rawValue == "application/vnd.github+json"
                    )
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    #expect(request.headers.first("User-Agent")?.rawValue == "swift-institute")
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    #expect(request.headers.first("X-GitHub-Api-Version")?.rawValue == "2026-03-10")
                    #expect(request.headers.first("Authorization") == nil)

                    return HTTP.Router.Response(
                        status: .ok,
                        headers: [],
                        content: Self.bytes(
                            #"[{"id":42,"name":"swift","archived":false,"disabled":false,"fork":false,"visibility":"public"}]"#
                        )
                    )
                },
                pagination: .init { _ in nil }
            )
            let client = http.repositories(authentication: .none)
            let page = try await client.page(Self.request)

            #expect(page.next == nil)
            #expect(page.response.repositories.count == 1)
            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(page.response.repositories.first?.id.underlying == 42)
            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(page.response.repositories.first?.name.underlying == "swift")
        }

        @Test("Authentication is injected explicitly into the HTTP adapter")
        func authentication() async throws {
            let http = GitHub.HTTP.Client<Fixture.Execution, Never>(
                agent: .init(rawValue: "swift-institute"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(Fixture.Execution) in
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    #expect(request.headers.first("Authorization")?.rawValue == "Bearer secret")
                    return HTTP.Router.Response(status: .ok, content: Self.bytes("[]"))
                },
                pagination: .none
            )
            let client = http.repositories(
                authentication: .token(.init(rawValue: "secret"))
            )

            _ = try await client.page(Self.request)
        }

        @Test
        func `Organization repositories map transport and malformed responses to C5 leaves`() async
        {
            let transport = GitHub.HTTP.Client<Fixture.Execution, Never>(
                agent: .init(rawValue: "swift-institute"),
                version: .init(rawValue: "2026-03-10"),
                execute: { _ async throws(Fixture.Execution) in throw .unexpected },
                pagination: .none
            ).repositories(authentication: .none)
            await #expect(
                throws:
                    Either<Async.Lifecycle.Error, GitHub.Organization.Repositories.Page.Error>
                    .right(.transport)
            ) {
                try await transport.page(Self.request)
            }

            let malformed = GitHub.HTTP.Client<Fixture.Execution, Never>(
                agent: .init(rawValue: "swift-institute"),
                version: .init(rawValue: "2026-03-10"),
                execute: { _ async throws(Fixture.Execution) in
                    .init(status: .internalServerError)
                },
                pagination: .none
            ).repositories(authentication: .none)
            await #expect(
                throws:
                    Either<Async.Lifecycle.Error, GitHub.Organization.Repositories.Page.Error>
                    .right(.malformedResponse)
            ) {
                try await malformed.page(Self.request)
            }
        }

        private static let request = GitHub.Organization.Repositories.Request(
            organization: .init("swiftlang"),
            type: .public,
            page: .first,
            size: .maximum
        )

        private static func bytes(_ string: String) -> [Byte] {
            string.utf8.map(Byte.init(bitPattern:))
        }
    }
}
