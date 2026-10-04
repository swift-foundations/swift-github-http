import GitHub_Standard
import HTTP
import HTTP_Router
import RFC_9110

extension GitHub.HTTP.Pagination {
    public struct Witness<Failure: Swift.Error>: Sendable {
        public var next: @Sendable (RFC_9110.Message.Headers) throws(Failure) -> GitHub.Page.Number?

        public init(
            next: @escaping @Sendable (RFC_9110.Message.Headers) throws(Failure) -> GitHub.Page.Number?
        ) {
            self.next = next
        }
    }
}
