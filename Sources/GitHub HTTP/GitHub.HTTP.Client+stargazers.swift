import GitHub
import GitHub_Standard
import HTTP_Standard
import JSON

extension GitHub.HTTP.Client {
    public func stargazers(
        authentication: GitHub.HTTP.Authentication
    ) -> GitHub.Repository.Stargazers.Client<
        GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>
    > {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>) in
            var parameters: [(String, String?)] = []
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

            let httpRequest: HTTP.Request
            do throws(GitHub.HTTP.Error<ExecutionFailure, Never>) {
                httpRequest = try self.request(
                    path: [
                        // swift-linter:disable:next raw value access
                        // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                        "repos", request.owner.underlying, request.repository.underlying,
                        "stargazers",
                    ],
                    query: parameters,
                    accept: "application/vnd.github.star+json",
                    authentication: authentication
                )
            } catch {
                throw error.widening()
            }

            let httpResponse: HTTP.Response
            do throws(GitHub.HTTP.Error<ExecutionFailure, Never>) {
                httpResponse = try await self.response(for: httpRequest)
            } catch {
                throw error.widening()
            }

            let response: GitHub.Repository.Stargazers.Response
            do throws(JSON.Error) {
                let elements = try [JSON].deserialize(JSON.parse(httpResponse.body ?? []))
                var stargazers: [GitHub.Repository.Stargazers.Stargazer] = []
                stargazers.reserveCapacity(elements.count)
                for element in elements {
                    stargazers.append(
                        try .init(
                            user: Self.user(from: element["user"]),
                            starredAt: Self.timestamp(element["starred_at"])
                        )
                    )
                }
                response = .init(stargazers: stargazers)
            } catch {
                throw .json(error)
            }

            let nextPage: GitHub.Page.Number?
            do throws(PaginationFailure) {
                nextPage = try self.pagination.next(httpResponse.headers)
            } catch {
                throw .pagination(error)
            }

            return .init(
                response: response,
                next: nextPage.map {
                    .init(
                        owner: request.owner,
                        repository: request.repository,
                        page: $0,
                        size: request.size
                    )
                }
            )
        }
    }
}
