import GitHub
import GitHub_Standard
import JSON

extension GitHub.HTTP.User.Authenticated.Emails.Accessor {
    public var list: GitHub.User.Authenticated.Emails.List.Client<
        GitHub.HTTP.Error<ExecutionFailure, Never>
    > {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) in
            let httpRequest = try self.client.request(
                path: ["user", "emails"],
                authentication: .token(.init(rawValue: request.accessToken))
            )
            let httpResponse = try await self.client.response(for: httpRequest)

            do throws(JSON.Error) {
                let elements = try [JSON].deserialize(JSON.parse(httpResponse.body ?? []))
                var emails: [GitHub.User.Authenticated.Emails.List.Email] = []
                emails.reserveCapacity(elements.count)
                for element in elements {
                    emails.append(
                        try .init(
                            email: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                                .email(element["email"]),
                            primary: Bool.deserialize(element["primary"]),
                            verified: Bool.deserialize(element["verified"]),
                            visibility: String?.deserialize(element["visibility"])
                        )
                    )
                }
                return .init(emails: emails)
            } catch {
                throw .json(error)
            }
        }
    }
}
