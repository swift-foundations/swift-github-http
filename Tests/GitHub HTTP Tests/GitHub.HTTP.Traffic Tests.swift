import GitHub_HTTP
import Testing

extension GitHub.HTTP {
    @Suite("GitHub.HTTP.Traffic.Unit")
    struct Traffic {
        @Test("All four traffic operations map distinct provider endpoints")
        func endpoints() async throws {
            let http = GitHub.HTTP.Client<Fixture.Execution, Never>(
                agent: .init(rawValue: "traffic-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(Fixture.Execution) in
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    #expect(request.headers.first("Accept")?.rawValue == "application/vnd.github+json")
                    // swift-linter:disable:next raw value access
                    // REASON: wire-shape assertion — typed value's wire form compared against expected wire literal ([PATTERN-017] boundary use, test-side of ruling class 3).
                    switch request.target.rawValue {
                    case "https://api.github.com/repos/swiftlang/swift/traffic/views?per=day":
                        return .init(
                            status: .ok,
                            body: Fixture.bytes(
                                #"{"count":12,"uniques":8,"views":[{"timestamp":"2026-07-21T00:00:00Z","count":5,"uniques":4}]}"#
                            )
                        )
                    case "https://api.github.com/repos/swiftlang/swift/traffic/clones?per=week":
                        return .init(
                            status: .ok,
                            body: Fixture.bytes(
                                #"{"count":6,"uniques":3,"clones":[{"timestamp":"2026-07-21T00:00:00Z","count":2,"uniques":1}]}"#
                            )
                        )
                    case "https://api.github.com/repos/swiftlang/swift/traffic/popular/paths":
                        return .init(
                            status: .ok,
                            body: Fixture.bytes(
                                #"[{"path":"/swiftlang/swift","title":"swift","count":10,"uniques":7}]"#
                            )
                        )
                    case "https://api.github.com/repos/swiftlang/swift/traffic/popular/referrers":
                        return .init(
                            status: .ok,
                            body: Fixture.bytes(
                                #"[{"referrer":"github.com","count":9,"uniques":6}]"#
                            )
                        )
                    default:
                        throw .unexpected
                    }
                },
                pagination: .none
            )
            let client = http.traffic(authentication: .none)
            let owner = GitHub.Owner.Login(rawValue: "swiftlang")
            let repository = GitHub.Repository.Name(rawValue: "swift")

            let views = try await client.views(
                .init(owner: owner, repository: repository, interval: .day)
            )
            let clones = try await client.clones(
                .init(owner: owner, repository: repository, interval: .week)
            )
            let paths = try await client.paths(.init(owner: owner, repository: repository))
            let referrers = try await client.referrers(
                .init(owner: owner, repository: repository)
            )

            #expect(views.count == 12)
            #expect(views.views.first?.count == 5)
            #expect(clones.uniques == 3)
            #expect(clones.clones.first?.uniques == 1)
            #expect(paths.paths.first?.path == "/swiftlang/swift")
            #expect(referrers.referrers.first?.referrer == "github.com")
        }

        @Test("Negative wire counts fail instead of converting")
        func negative() async throws {
            let http = GitHub.HTTP.Client<Fixture.Execution, Never>(
                agent: .init(rawValue: "traffic-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { _ async throws(Fixture.Execution) in
                    .init(
                        status: .ok,
                        body: Fixture.bytes(#"{"count":-1,"uniques":0,"views":[]}"#)
                    )
                },
                pagination: .none
            )

            do throws(GitHub.HTTP.Error<Fixture.Execution, Never>) {
                _ = try await http.traffic(authentication: .none).views(
                    .init(
                        owner: .init(rawValue: "swiftlang"),
                        repository: .init(rawValue: "swift")
                    )
                )
                Issue.record("Expected a typed JSON conversion failure")
            } catch let error {
                guard case .json = error else {
                    Issue.record("Expected JSON failure, got \(error)")
                    return
                }
            }
        }
    }
}
