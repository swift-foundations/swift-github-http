import GitHub
import GitHub_Standard
import RFC_3986

extension GitHub.HTTP.OAuth.Accessor {
    public var authorization:
        GitHub.OAuth.Authorization.Client<
            GitHub.HTTP.Error<Never, Never>
        >
    {
        .init { request throws(GitHub.HTTP.Error<Never, Never>) in
            let scheme: RFC_3986.URI.Scheme
            do throws(RFC_3986.URI.Scheme.Error) {
                scheme = try .init("https")
            } catch {
                throw .scheme(error)
            }

            let path: RFC_3986.URI.Path
            do throws(RFC_3986.URI.Path.Error) {
                path = try .init(segments: ["login", "oauth", "authorize"])
            } catch {
                throw .path(error)
            }

            let uri = RFC_3986.URI(
                scheme: scheme,
                authority: .init(host: .registeredName("github.com")),
                path: path
            )
            .appendingQueryItem(name: "client_id", value: request.clientID)
            .appendingQueryItem(
                name: "redirect_uri",
                value: request.redirectURI.description
            )
            .appendingQueryItem(
                name: "scope",
                value: request.scopes.joined(separator: " ")
            )
            .appendingQueryItem(name: "state", value: request.state)

            return .init(uri: uri)
        }
    }
}
