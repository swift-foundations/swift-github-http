import GitHub
import HTTP_Standard

extension GitHub.HTTP {
    public struct Client<ExecutionFailure, PaginationFailure>: Sendable
    where
        ExecutionFailure: Swift.Error,
        PaginationFailure: Swift.Error
    {
        public let agent: Agent
        public let version: Version
        public var execute: @Sendable (HTTP.Request) async throws(ExecutionFailure) -> HTTP.Response
        public var pagination: Pagination.Witness<PaginationFailure>

        public init(
            agent: Agent,
            version: Version,
            execute:
                @escaping @Sendable (HTTP.Request) async throws(ExecutionFailure) -> HTTP.Response,
            pagination: Pagination.Witness<PaginationFailure>
        ) {
            self.agent = agent
            self.version = version
            self.execute = execute
            self.pagination = pagination
        }
    }
}
