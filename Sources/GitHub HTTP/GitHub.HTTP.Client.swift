import GitHub
import HTTP
import HTTP_Router
import RFC_9110

extension GitHub.HTTP {
    public struct Client<ExecutionFailure, PaginationFailure>: Sendable
    where
        ExecutionFailure: Swift.Error,
        PaginationFailure: Swift.Error
    {
        public let agent: Agent
        public let version: Version
        public var execute: @Sendable (HTTP.Router.Request) async throws(ExecutionFailure) -> HTTP.Router.Response
        public var pagination: Pagination.Witness<PaginationFailure>

        public init(
            agent: Agent,
            version: Version,
            execute:
                @escaping @Sendable (HTTP.Router.Request) async throws(ExecutionFailure) -> HTTP.Router.Response,
            pagination: Pagination.Witness<PaginationFailure>
        ) {
            self.agent = agent
            self.version = version
            self.execute = execute
            self.pagination = pagination
        }
    }
}
