import GitHub
import GitHub_Standard
import JSON

extension GitHub.HTTP.User.Authenticated.Accessor {
    public var get: GitHub.User.Authenticated.Get.Client<
        GitHub.HTTP.Error<ExecutionFailure, Never>
    > {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) in
            let httpRequest = try self.client.request(
                path: ["user"],
                authentication: .token(.init(rawValue: request.accessToken))
            )
            let httpResponse = try await self.client.response(for: httpRequest)

            do throws(JSON.Error) {
                let json = try JSON.parse(httpResponse.body ?? [])
                return try .init(
                    user: .init(
                        id: .init(
                            GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                                .nonnegative(json["id"], expected: "nonnegative user id")
                        ),
                        login: .init(String.deserialize(json["login"])),
                        name: String?.deserialize(json["name"]),
                        email: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .email(ifPresent: json["email"]),
                        avatarURL: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .uri(json["avatar_url"]),
                        bio: String?.deserialize(json["bio"]),
                        company: String?.deserialize(json["company"]),
                        blog: String?.deserialize(json["blog"]),
                        location: String?.deserialize(json["location"]),
                        publicRepos: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .nonnegative(json["public_repos"], expected: "nonnegative public repo count"),
                        publicGists: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .nonnegative(json["public_gists"], expected: "nonnegative public gist count"),
                        followers: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .nonnegative(json["followers"], expected: "nonnegative follower count"),
                        following: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .nonnegative(json["following"], expected: "nonnegative following count"),
                        createdAt: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .timestamp(json["created_at"]),
                        updatedAt: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>
                            .timestamp(json["updated_at"])
                    )
                )
            } catch {
                throw .json(error)
            }
        }
    }
}
