import GitHub
import GitHub_Standard
import HTTP_Standard
import JSON

extension GitHub.HTTP.User.Accessor {
    public func repositories(
        authentication: GitHub.HTTP.Authentication
    ) -> GitHub.User.Repositories.Client<
        GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>
    > {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>) in
            var parameters: [(String, String?)] = []
            if let visibility = request.visibility {
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                parameters.append(("visibility", visibility.rawValue))
            }
            if let affiliation = request.affiliation {
                parameters.append(("affiliation", affiliation))
            }
            if let type = request.type {
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                parameters.append(("type", type.rawValue))
            }
            if let sort = request.sort {
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                parameters.append(("sort", sort.rawValue))
            }
            if let direction = request.direction {
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                parameters.append(("direction", direction.rawValue))
            }
            if let size = request.size {
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                parameters.append(("per_page", String(size.rawValue)))
            }
            if let page = request.page {
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                parameters.append(("page", String(page.rawValue)))
            }
            if let since = request.since {
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                parameters.append(("since", since.rawValue))
            }
            if let before = request.before {
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                parameters.append(("before", before.rawValue))
            }

            let httpRequest: HTTP.Request
            do throws(GitHub.HTTP.Error<ExecutionFailure, Never>) {
                httpRequest = try self.client.request(
                    path: ["user", "repos"],
                    query: parameters,
                    authentication: authentication
                )
            } catch {
                throw error.widening()
            }

            let httpResponse: HTTP.Response
            do throws(GitHub.HTTP.Error<ExecutionFailure, Never>) {
                httpResponse = try await self.client.response(for: httpRequest)
            } catch {
                throw error.widening()
            }

            let response: GitHub.User.Repositories.Response
            do throws(JSON.Error) {
                let elements = try [JSON].deserialize(JSON.parse(httpResponse.body ?? []))
                var repositories: [GitHub.Repository.Metadata] = []
                repositories.reserveCapacity(elements.count)
                for element in elements {
                    repositories.append(
                        try GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .metadata(from: element)
                    )
                }
                response = .init(repositories: repositories)
            } catch {
                throw .json(error)
            }

            let nextPage: GitHub.Page.Number?
            do throws(PaginationFailure) {
                nextPage = try self.client.pagination.next(httpResponse.headers)
            } catch {
                throw .pagination(error)
            }

            return .init(
                response: response,
                next: nextPage.map {
                    .init(
                        visibility: request.visibility,
                        affiliation: request.affiliation,
                        type: request.type,
                        sort: request.sort,
                        direction: request.direction,
                        page: $0,
                        size: request.size,
                        since: request.since,
                        before: request.before
                    )
                }
            )
        }
    }
}
