import GitHub_HTTP
import Testing

extension GitHub.HTTP.Pagination {
    @Suite
    struct Unit {
        @Test("A next relation maps its explicit page into the semantic page number")
        func success() throws {
            let next = try witness.next(
                headers(
                    "<https://api.github.com/orgs/swiftlang/repos?type=public&per_page=100&page=2>; rel=next"
                )
            )

            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(next?.rawValue == 2)
        }

        @Test("The next relation is selected from a multi-link field")
        func multiple() throws {
            let next = try witness.next(
                headers(
                    "<https://api.github.com/orgs/swiftlang/repos?page=1>; rel=prev, "
                        + "<https://api.github.com/orgs/swiftlang/repos?page=3>; rel=\"next\""
                )
            )

            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(next?.rawValue == 3)
        }

        @Test("Absence of a next relation ends pagination")
        func absent() throws {
            let next = try witness.next(
                headers("<https://api.github.com/orgs/swiftlang/repos?page=1>; rel=prev")
            )

            #expect(next == nil)
        }

        @Test("A malformed Link field is a typed pagination failure")
        func malformed() throws {
            #expect(throws: GitHub.HTTP.Pagination.Error.self) {
                _ = try witness.next(headers("<unterminated; rel=next"))
            }
        }

        private let witness = GitHub.HTTP.Pagination.Witness<GitHub.HTTP.Pagination.Error>.link

        private func headers(_ value: String) throws -> HTTP.Headers {
            try .init([.init(name: "Link", value: value)])
        }
    }
}
