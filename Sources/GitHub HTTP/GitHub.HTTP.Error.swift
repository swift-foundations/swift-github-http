import HTTP_Standard
import JSON
import RFC_3986

extension GitHub.HTTP {
    public enum Error<ExecutionFailure, PaginationFailure>: Swift.Error, Sendable
    where
        ExecutionFailure: Swift.Error & Sendable,
        PaginationFailure: Swift.Error & Sendable
    {
        case execute(ExecutionFailure)
        case header(HTTP.Header.Field.Error)
        case json(JSON.Error)
        case pagination(PaginationFailure)
        case path(RFC_3986.URI.Path.Error)
        case query(RFC_3986.URI.Query.Error)
        case scheme(RFC_3986.URI.Scheme.Error)
        case status(HTTP.Status)
    }
}
