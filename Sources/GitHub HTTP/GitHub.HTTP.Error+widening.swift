extension GitHub.HTTP.Error where PaginationFailure == Never {
    func widening<NewPaginationFailure>() -> GitHub.HTTP.Error<
        ExecutionFailure,
        NewPaginationFailure
    > where NewPaginationFailure: Swift.Error {
        switch self {
        case .execute(let error): return .execute(error)
        case .header(let error): return .header(error)
        case .json(let error): return .json(error)
        case .pagination(let never): switch never {}
        case .path(let error): return .path(error)
        case .query(let error): return .query(error)
        case .scheme(let error): return .scheme(error)
        case .status(let status): return .status(status)
        }
    }
}
