import GitHub
import GitHub_Standard
import HTTP_Standard
import JSON
import RFC_3986

extension GitHub.HTTP.Client {
    public func repositories(
        authentication: GitHub.HTTP.Authentication
    ) -> GitHub.Organization.Repositories.Client<GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>> {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>) in
            let path: RFC_3986.URI.Path
            do throws(RFC_3986.URI.Path.Error) {
                path = try .init(
                    segments: ["orgs", request.organization.rawValue, "repos"]
                )
            } catch {
                throw .path(error)
            }

            let query: RFC_3986.URI.Query
            do throws(RFC_3986.URI.Query.Error) {
                query = try .init([
                    ("type", request.type.rawValue),
                    ("per_page", String(request.size.rawValue)),
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
                    try .init(name: "User-Agent", value: self.agent.rawValue)
                )
                headers.append(
                    try .init(name: "X-GitHub-Api-Version", value: self.version.rawValue)
                )
                if case .token(let token) = authentication {
                    headers.append(
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

            let next: GitHub.Organization.Repositories.Request?
            do throws(PaginationFailure) {
                next = try self.pagination.next(httpResponse.headers, request)
            } catch {
                throw .pagination(error)
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
            let rawVisibility = try String.deserialize(element["visibility"])
            guard let visibility = GitHub.Repository.Visibility(rawValue: rawVisibility) else {
                throw JSON.Error.typeMismatch(
                    expected: "public, private, or internal visibility",
                    got: rawVisibility
                )
            }

            repositories.append(
                .init(
                    id: .init(rawValue: id),
                    name: .init(rawValue: name),
                    archived: archived,
                    visibility: visibility
                )
            )
        }

        return .init(repositories: repositories)
    }
}
