@testable import GitHub_HTTP

extension GitHub.HTTP {
    enum Fixture {
        enum Execution: Swift.Error, Equatable, Sendable {
            case unexpected
        }

        enum Pagination: Swift.Error, Equatable, Sendable {
            case unexpected
        }
    }
}
