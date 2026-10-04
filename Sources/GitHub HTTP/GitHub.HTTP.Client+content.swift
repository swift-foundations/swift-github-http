import GitHub
import GitHub_Standard
import HTTP
import HTTP_Router
import RFC_9110
import JSON
import RFC_3986
import RFC_3986_Coder

extension GitHub.HTTP.Client {
    public func content(
        authentication: GitHub.HTTP.Authentication
    ) -> GitHub.Repository.Content.Client<GitHub.HTTP.Error<ExecutionFailure, Never>> {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) in
            let path: RFC_3986.URI.Path
            do throws(RFC_3986.URI.Path.Error) {
                path = try .init(
                    segments: [
                        "repos",
                        request.organization.underlying,
                        request.repository.underlying,
                        "contents",
                    ] + request.path.segments
                )
            } catch {
                throw .path(error)
            }

            let scheme: RFC_3986.URI.Scheme
            do throws(RFC_3986.URI.Scheme.Error) {
                scheme = try .init("https")
            } catch {
                throw .scheme(error)
            }

            var headers = RFC_9110.Message.Headers()
            do throws(RFC_9110.Field.Error) {
                headers.append(
                    try .init(name: "Accept", value: "application/vnd.github+json")
                )
                headers.append(
                    // swift-linter:disable:next raw value access
                    // REASON: wire-format extraction; raw agent string is the header value
                    try .init(name: "User-Agent", value: self.agent.rawValue)
                )
                headers.append(
                    // swift-linter:disable:next raw value access
                    // REASON: wire-format extraction; raw version string is the header value
                    try .init(name: "X-GitHub-Api-Version", value: self.version.rawValue)
                )
                if case .token(let token) = authentication {
                    headers.append(
                        // swift-linter:disable:next raw value access
                        // REASON: wire-format extraction; raw token string is the bearer value
                        try .init(name: "Authorization", value: "Bearer \(token.rawValue)")
                    )
                }
            } catch {
                throw .header(error)
            }

            let uri = RFC_3986.URI(
                scheme: scheme,
                authority: .init(host: .registeredName("api.github.com")),
                path: path
            )
            let httpRequest = HTTP.Router.Request(
                method: .get,
                target: .resource(uri),
                headers: headers
            )

            let httpResponse: HTTP.Router.Response
            do throws(ExecutionFailure) {
                httpResponse = try await self.execute(httpRequest)
            } catch {
                throw .execute(error)
            }

            guard httpResponse.status != .notFound else { return nil }
            guard httpResponse.status.isSuccessful else {
                throw .status(httpResponse.status)
            }

            do throws(JSON.Error) {
                let json = try JSON.parse(httpResponse.content ?? [])
                let rawKind = try String.deserialize(json["type"])
                guard let kind = GitHub.Repository.Content.Kind(rawValue: rawKind) else {
                    throw JSON.Error.typeMismatch(
                        expected: "dir, file, submodule, or symlink content type",
                        got: rawKind
                    )
                }
                return .init(kind: kind)
            } catch {
                throw .json(error)
            }
        }
    }
}
