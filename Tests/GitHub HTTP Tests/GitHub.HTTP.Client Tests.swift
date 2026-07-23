import GitHub_HTTP
import Testing

extension GitHub.HTTP {
    @Suite("GitHub.HTTP.Client.Unit")
    struct Unit {
        @Test("The product re-exports the HTTP execute surface")
        func exports() {
            let headers = HTTP.Headers()
            let request = HTTP.Request(method: .options, target: .asterisk, headers: headers)
            let response = HTTP.Response(status: .ok, headers: headers)

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

                    return HTTP.Response(
                        status: .ok,
                        headers: [],
                        body: Self.bytes(
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
            #expect(page.response.repositories.first?.id.rawValue == 42)
            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(page.response.repositories.first?.name.rawValue == "swift")
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
                    return HTTP.Response(status: .ok, body: Self.bytes("[]"))
                },
                pagination: .none
            )
            let client = http.repositories(
                authentication: .token(.init(rawValue: "secret"))
            )

            _ = try await client.page(Self.request)
        }

        private static let request = GitHub.Organization.Repositories.Request(
            organization: .init(rawValue: "swiftlang"),
            type: .public,
            page: .first,
            size: .maximum
        )

        private static func bytes(_ string: String) -> [Byte] {
            string.utf8.map(Byte.init)
        }
    }
}
