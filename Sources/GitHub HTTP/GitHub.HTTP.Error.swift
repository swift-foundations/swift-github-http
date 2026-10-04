import HTTP
import HTTP_Router
import RFC_9110
import JSON
import RFC_3986

extension GitHub.HTTP {
    public enum Error<ExecutionFailure, PaginationFailure>: Swift.Error, Sendable
    where
        ExecutionFailure: Swift.Error,
        PaginationFailure: Swift.Error
    {
        case execute(ExecutionFailure)
        case header(RFC_9110.Field.Error)
        case json(JSON.Error)
        case pagination(PaginationFailure)
        case path(RFC_3986.URI.Path.Error)
        case query(RFC_3986.URI.Query.Error)
        case scheme(RFC_3986.URI.Scheme.Error)
        case status(RFC_9110.Status)
    }
}
