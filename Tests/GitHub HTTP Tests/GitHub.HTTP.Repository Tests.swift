import GitHub_HTTP
import Testing

extension GitHub.HTTP {
    @Suite("GitHub.HTTP.Repository.Unit")
    struct Repository {
        @Test("Repository.Get decodes complete canonical metadata")
        func get() async throws {
            let http = GitHub.HTTP.Client<Fixture.Execution, Never>(
                agent: .init(rawValue: "repository-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(Fixture.Execution) in
                    #expect(
                        // swift-linter:disable:next raw value access
                        // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                        request.target.rawValue
                            == "https://api.github.com/repos/swiftlang/swift"
                    )
                    return .init(status: .ok, body: Fixture.bytes(Fixture.metadata))
                },
                pagination: .none
            )
            let response = try await http.repository(authentication: .none).get(
                .init(
                    owner: .init(rawValue: "swiftlang"),
                    repository: .init(rawValue: "swift")
                )
            )

            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(response.repository.id.rawValue == 42)
            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(response.repository.owner.login.rawValue == "swiftlang")
            #expect(response.repository.stargazersCount == 70_000)
            #expect(response.repository.license?.spdxID == "Apache-2.0")
            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(response.repository.pushedAt?.rawValue == "2026-07-22T18:00:00Z")
        }
    }
}
