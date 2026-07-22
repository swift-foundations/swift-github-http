import GitHub
import HTTP_Standard

extension GitHub.HTTP {
    public struct Pagination<Failure: Swift.Error & Sendable>: Sendable {
        public var next:
            @Sendable (
                HTTP.Headers,
                GitHub.Organization.Repositories.Request
            ) throws(Failure) -> GitHub.Organization.Repositories.Request?

        public init(
            next: @escaping @Sendable (
                HTTP.Headers,
                GitHub.Organization.Repositories.Request
            ) throws(Failure) -> GitHub.Organization.Repositories.Request?
        ) {
            self.next = next
        }
    }
}

extension GitHub.HTTP.Pagination where Failure == Never {
    public static let none = Self { _, _ in nil }
}
