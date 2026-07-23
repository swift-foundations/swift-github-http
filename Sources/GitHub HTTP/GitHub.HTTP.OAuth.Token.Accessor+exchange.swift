import GitHub
import GitHub_Standard
import HTML_Form_Coder
import HTML_Standard
import HTTP_Body
import HTTP_Standard
import JSON
import RFC_3986

extension GitHub.HTTP.OAuth.Token.Accessor {
    public var exchange: GitHub.OAuth.Token.Exchange.Client<
        GitHub.HTTP.OAuth.Error<ExecutionFailure>
    > {
        .init { request async throws(GitHub.HTTP.OAuth.Error<ExecutionFailure>) in
            let httpRequest: HTTP.Request
            do throws(GitHub.HTTP.Error<ExecutionFailure, Never>) {
                let scheme: RFC_3986.URI.Scheme
                do throws(RFC_3986.URI.Scheme.Error) {
                    scheme = try .init("https")
                } catch {
                    throw .scheme(error)
                }

                let path: RFC_3986.URI.Path
                do throws(RFC_3986.URI.Path.Error) {
                    path = try .init(segments: ["login", "oauth", "access_token"])
                } catch {
                    throw .path(error)
                }

                var headers = HTTP.Headers()
                do throws(HTTP.Header.Field.Error) {
                    headers.append(try .init(name: "Accept", value: "application/json"))
                    headers.append(
                        // swift-linter:disable:next raw value access
                        // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                        try .init(name: "User-Agent", value: self.client.agent.rawValue)
                    )
                } catch {
                    throw .header(error)
                }

                var value = HTML.Form.Data.Entry.List(entries: [
                    .init(name: "client_id", stringValue: request.clientID),
                    .init(name: "client_secret", stringValue: request.clientSecret),
                    .init(name: "code", stringValue: request.code),
                ])
                if let redirectURI = request.redirectURI {
                    value.append(
                        .init(name: "redirect_uri", stringValue: redirectURI.description)
                    )
                }

                var result = HTTP.Request(
                    method: .post,
                    target: .absolute(
                        .init(
                            scheme: scheme,
                            authority: .init(host: .registeredName("github.com")),
                            path: path
                        )
                    ),
                    headers: headers
                )
                result.body(set: value, using: HTML.Form.Coder())
                httpRequest = result
            } catch {
                throw .http(error)
            }

            let httpResponse: HTTP.Response
            do throws(GitHub.HTTP.Error<ExecutionFailure, Never>) {
                httpResponse = try await self.client.response(for: httpRequest)
            } catch {
                throw .http(error)
            }

            let json: JSON
            do throws(JSON.Error) {
                json = try JSON.parse(httpResponse.body ?? [])
            } catch {
                throw .http(.json(error))
            }

            if !json["error"].isNull {
                let providerError: GitHub.OAuth.Token.Exchange.Error
                do throws(JSON.Error) {
                    providerError = try .init(
                        error: String.deserialize(json["error"]),
                        errorDescription: String?.deserialize(json["error_description"]),
                        errorURI: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .uri(ifPresent: json["error_uri"])
                    )
                } catch {
                    throw .http(.json(error))
                }
                throw .provider(providerError)
            }

            do throws(JSON.Error) {
                return try .init(
                    accessToken: String.deserialize(json["access_token"]),
                    tokenType: String.deserialize(json["token_type"]),
                    scope: String.deserialize(json["scope"])
                )
            } catch {
                throw .http(.json(error))
            }
        }
    }
}
