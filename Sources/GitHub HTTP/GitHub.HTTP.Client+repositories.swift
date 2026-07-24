import GitHub
import GitHub_Standard
import HTTP_Standard
import JSON
import RFC_3986

extension GitHub.HTTP.Client {
    public func repositories(
        authentication: GitHub.HTTP.Authentication
    )
        -> GitHub.Organization.Repositories.Client<
            GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>
        >
    {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>) in
            let path: RFC_3986.URI.Path
            do throws(RFC_3986.URI.Path.Error) {
                path = try .init(
                    // swift-linter:disable:next raw value access
                    // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                    segments: ["orgs", request.organization.underlying, "repos"]
                )
            } catch {
                throw .path(error)
            }

            let query: RFC_3986.URI.Query
            do throws(RFC_3986.URI.Query.Error) {
                query = try .init([
                    // swift-linter:disable:next raw value access
                    // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                    ("type", request.type.rawValue),
                    // swift-linter:disable:next raw value access
                    // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                    ("per_page", String(request.size.rawValue)),
                    // swift-linter:disable:next raw value access
                    // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                    ("page", String(request.page.rawValue)),
                ])
            } catch {
                throw .query(error)
            }

            let scheme: RFC_3986.URI.Scheme
            do throws(RFC_3986.URI.Scheme.Error) {
                scheme = try .init("https")
            } catch {
                throw .scheme(error)
            }

            var headers = HTTP.Headers()
            do throws(HTTP.Header.Field.Error) {
                headers.append(
                    try .init(name: "Accept", value: "application/vnd.github+json")
                )
                headers.append(
                    // swift-linter:disable:next raw value access
                    // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                    try .init(name: "User-Agent", value: self.agent.rawValue)
                )
                headers.append(
                    // swift-linter:disable:next raw value access
                    // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                    try .init(name: "X-GitHub-Api-Version", value: self.version.rawValue)
                )
                if case .token(let token) = authentication {
                    headers.append(
                        // swift-linter:disable:next raw value access
                        // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                        try .init(name: "Authorization", value: "Bearer \(token.rawValue)")
                    )
                }
            } catch {
                throw .header(error)
            }

            let uri = RFC_3986.URI(
                scheme: scheme,
                authority: .init(host: .registeredName("api.github.com")),
                path: path,
                query: query
            )
            let httpRequest = HTTP.Request(
                method: .get,
                target: .absolute(uri),
                headers: headers
            )

            let httpResponse: HTTP.Response
            do throws(ExecutionFailure) {
                httpResponse = try await self.execute(httpRequest)
            } catch {
                throw .execute(error)
            }

            guard httpResponse.status.isSuccessful else {
                throw .status(httpResponse.status)
            }

            let response: GitHub.Organization.Repositories.Response
            do throws(JSON.Error) {
                response = try Self.response(from: httpResponse.body ?? [])
            } catch {
                throw .json(error)
            }

            let nextPage: GitHub.Page.Number?
            do throws(PaginationFailure) {
                nextPage = try self.pagination.next(httpResponse.headers)
            } catch {
                throw .pagination(error)
            }

            let next = nextPage.map {
                GitHub.Organization.Repositories.Request(
                    organization: request.organization,
                    type: request.type,
                    page: $0,
                    size: request.size
                )
            }

            return .init(response: response, next: next)
        }
    }
}

extension GitHub.HTTP.Client {
    private static func response(
        from body: [Byte]
    ) throws(JSON.Error) -> GitHub.Organization.Repositories.Response {
        let json = try JSON.parse(body)
        guard let elements = json.array else {
            throw JSON.Error.typeMismatch(expected: "array", got: "non-array")
        }

        var repositories: [GitHub.Repository.Summary] = []
        repositories.reserveCapacity(elements.count)

        for element in elements {
            let rawID = try Int64.deserialize(element["id"])
            guard let id = UInt64(exactly: rawID) else {
                throw JSON.Error.typeMismatch(
                    expected: "nonnegative repository id",
                    got: String(rawID)
                )
            }
            let name = try String.deserialize(element["name"])
            let archived = try Bool.deserialize(element["archived"])
            let disabled = try Bool.deserialize(element["disabled"])
            let fork = try Bool.deserialize(element["fork"])
            let rawVisibility = try String.deserialize(element["visibility"])
            guard let visibility = GitHub.Repository.Visibility(rawValue: rawVisibility) else {
                throw JSON.Error.typeMismatch(
                    expected: "public, private, or internal visibility",
                    got: rawVisibility
                )
            }

            repositories.append(
                .init(
                    id: .init(id),
                    name: .init(name),
                    archived: archived,
                    disabled: disabled,
                    fork: fork,
                    visibility: visibility
                )
            )
        }

        return .init(repositories: repositories)
    }
}
