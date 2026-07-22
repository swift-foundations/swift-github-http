import GitHub
import HTTP_Standard

extension GitHub.HTTP {
    public struct Client<ExecutionFailure, PaginationFailure>: Sendable
    where
        ExecutionFailure: Swift.Error & Sendable,
        PaginationFailure: Swift.Error & Sendable
    {
        public let agent: Agent
        public let version: Version
        public var execute: @Sendable (HTTP.Request) async throws(ExecutionFailure) -> HTTP.Response
        public var pagination: Pagination<PaginationFailure>

        public init(
            agent: Agent,
            version: Version,
            execute: @escaping @Sendable (HTTP.Request) async throws(ExecutionFailure) -> HTTP.Response,
            pagination: Pagination<PaginationFailure>
        ) {
            self.agent = agent
            self.version = version
            self.execute = execute
            self.pagination = pagination
        }
    }
}
