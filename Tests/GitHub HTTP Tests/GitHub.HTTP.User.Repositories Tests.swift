import GitHub_HTTP
import Testing

extension GitHub.HTTP.User {
    @Suite("GitHub.HTTP.User.Repositories.Unit")
    struct Repositories {
        @Test("Authenticated-user repositories preserve filters across pages")
        func page() async throws {
            let headers = try HTTP.Headers([
                .init(
                    name: "Link",
                    value: "<https://api.github.com/user/repos?page=3>; rel=next"
                )
            ])
            let http = GitHub.HTTP.Client<GitHub.HTTP.Fixture.Execution, GitHub.HTTP.Pagination.Error>(
                agent: .init(rawValue: "user-repository-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(GitHub.HTTP.Fixture.Execution) in
                    #expect(
                        // swift-linter:disable:next raw value access
                        // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                        request.target.rawValue
                            == "https://api.github.com/user/repos?visibility=private&affiliation=owner,collaborator&type=owner&sort=updated&direction=desc&per_page=100&page=1"
                    )
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    #expect(request.headers.first("Authorization")?.rawValue == "Bearer secret")
                    return .init(
                        status: .ok,
                        headers: headers,
                        body: GitHub.HTTP.Fixture.bytes("[\(GitHub.HTTP.Fixture.metadata)]")
                    )
                },
                pagination: .link
            )
            let page = try await http.user.repositories(
                authentication: .token(.init(rawValue: "secret"))
            ).page(
                .init(
                    visibility: .private,
                    affiliation: "owner,collaborator",
                    type: .owner,
                    sort: .updated,
                    direction: .descending,
                    page: .first,
                    size: .maximum
                )
            )

            #expect(page.response.repositories.first?.fullName == "swiftlang/swift")
            #expect(page.next?.visibility == .private)
            #expect(page.next?.affiliation == "owner,collaborator")
            #expect(page.next?.type == .owner)
            #expect(page.next?.sort == .updated)
            #expect(page.next?.direction == .descending)
            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(page.next?.page?.rawValue == 3)
            #expect(page.next?.size == .maximum)
        }
    }
}
