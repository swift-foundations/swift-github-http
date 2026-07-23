import GitHub_HTTP
import Testing

extension GitHub.HTTP.User.Authenticated {
    @Suite("GitHub.HTTP.User.Authenticated.Unit")
    struct Tests {
        @Test("Get maps the authenticated-user endpoint and typed profile")
        func get() async throws {
            let http = GitHub.HTTP.Client<GitHub.HTTP.Fixture.Execution, Never>(
                agent: .init(rawValue: "user-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(GitHub.HTTP.Fixture.Execution) in
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    #expect(request.target.rawValue == "https://api.github.com/user")
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    #expect(request.headers.first("Authorization")?.rawValue == "Bearer token")
                    return .init(
                        status: .ok,
                        body: GitHub.HTTP.Fixture.bytes(
                            #"{"id":9,"login":"octocat","name":"The Octocat","email":null,"avatar_url":"https://avatars.githubusercontent.com/u/9","bio":null,"company":"@github","blog":"https://github.blog","location":"San Francisco","public_repos":8,"public_gists":8,"followers":100,"following":0,"created_at":"2020-01-01T00:00:00Z","updated_at":"2026-07-22T00:00:00Z"}"#
                        )
                    )
                },
                pagination: .none
            )
            let response = try await http.user.authenticated.get.get(
                .init(accessToken: "token")
            )

            // swift-linter:disable:next raw value access
            // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
            #expect(response.user.login.rawValue == "octocat")
            #expect(response.user.email == nil)
            #expect(response.user.publicRepos == 8)
        }

        @Test("Emails list maps typed non-null provider emails")
        func emails() async throws {
            let http = GitHub.HTTP.Client<GitHub.HTTP.Fixture.Execution, Never>(
                agent: .init(rawValue: "user-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(GitHub.HTTP.Fixture.Execution) in
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    #expect(request.target.rawValue == "https://api.github.com/user/emails")
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    #expect(request.headers.first("Authorization")?.rawValue == "Bearer token")
                    return .init(
                        status: .ok,
                        body: GitHub.HTTP.Fixture.bytes(
                            #"[{"email":"octocat@github.com","primary":true,"verified":true,"visibility":"public"}]"#
                        )
                    )
                },
                pagination: .none
            )
            let response = try await http.user.authenticated.emails.list.list(
                .init(accessToken: "token")
            )

            #expect(response.emails.first?.email.address == "octocat@github.com")
            #expect(response.emails.first?.primary == true)
            #expect(response.emails.first?.verified == true)
        }
    }
}
