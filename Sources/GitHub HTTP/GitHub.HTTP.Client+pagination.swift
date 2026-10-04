import HTTP
import HTTP_Router
import RFC_9110

extension GitHub.HTTP.Client where PaginationFailure == GitHub.HTTP.Pagination.Error {
    /// Creates a GitHub HTTP client with RFC 8288 Link-field pagination.
    public init(
        agent: GitHub.HTTP.Agent,
        version: GitHub.HTTP.Version,
        execute: @escaping @Sendable (HTTP.Router.Request) async throws(ExecutionFailure) -> HTTP.Router.Response
    ) {
        self.init(
            agent: agent,
            version: version,
            execute: execute,
            pagination: .link
        )
    }
}
