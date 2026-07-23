import GitHub

extension GitHub.HTTP.OAuth {
    public enum Error<ExecutionFailure>: Swift.Error, Sendable
    where ExecutionFailure: Swift.Error {
        case http(GitHub.HTTP.Error<ExecutionFailure, Never>)
        case provider(GitHub.OAuth.Token.Exchange.Error)
    }
}
