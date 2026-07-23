extension GitHub.HTTP.OAuth {
    public struct Accessor<ExecutionFailure, PaginationFailure>: Sendable
    where
        ExecutionFailure: Swift.Error,
        PaginationFailure: Swift.Error
    {
        let client: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>

        init(client: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>) {
            self.client = client
        }
    }
}
