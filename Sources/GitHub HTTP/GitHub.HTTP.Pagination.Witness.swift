import GitHub_Standard
import HTTP_Standard

extension GitHub.HTTP.Pagination {
    public struct Witness<Failure: Swift.Error>: Sendable {
        public var next: @Sendable (HTTP.Headers) throws(Failure) -> GitHub.Page.Number?

        public init(
            next: @escaping @Sendable (HTTP.Headers) throws(Failure) -> GitHub.Page.Number?
        ) {
            self.next = next
        }
    }
}
