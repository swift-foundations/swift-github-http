import GitHub
import GitHub_Standard
import JSON

extension GitHub.HTTP.Client {
    public func traffic(
        authentication: GitHub.HTTP.Authentication
    ) -> GitHub.Repository.Traffic.Client<
        GitHub.HTTP.Error<ExecutionFailure, Never>
    > {
        .init(
            views: { request async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) in
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                let parameters = request.interval.map { [("per", Optional($0.rawValue))] } ?? []
                let httpRequest = try self.request(
                    path: [
                        // swift-linter:disable:next raw value access
                        // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                        "repos", request.owner.rawValue, request.repository.rawValue,
                        "traffic", "views",
                    ],
                    query: parameters,
                    authentication: authentication
                )
                let httpResponse = try await self.response(for: httpRequest)

                do throws(JSON.Error) {
                    let json = try JSON.parse(httpResponse.body ?? [])
                    let elements = try [JSON].deserialize(json["views"])
                    var views: [GitHub.Repository.Traffic.Views.View] = []
                    views.reserveCapacity(elements.count)
                    for element in elements {
                        views.append(
                            try .init(
                                timestamp: Self.timestamp(element["timestamp"]),
                                count: Self.nonnegative(
                                    element["count"], expected: "nonnegative view count"
                                ),
                                uniques: Self.nonnegative(
                                    element["uniques"],
                                    expected: "nonnegative unique view count"
                                )
                            )
                        )
                    }
                    return try .init(
                        count: Self.nonnegative(json["count"], expected: "nonnegative view count"),
                        uniques: Self.nonnegative(
                            json["uniques"], expected: "nonnegative unique view count"
                        ),
                        views: views
                    )
                } catch {
                    throw .json(error)
                }
            },
            clones: { request async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) in
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                let parameters = request.interval.map { [("per", Optional($0.rawValue))] } ?? []
                let httpRequest = try self.request(
                    path: [
                        // swift-linter:disable:next raw value access
                        // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                        "repos", request.owner.rawValue, request.repository.rawValue,
                        "traffic", "clones",
                    ],
                    query: parameters,
                    authentication: authentication
                )
                let httpResponse = try await self.response(for: httpRequest)

                do throws(JSON.Error) {
                    let json = try JSON.parse(httpResponse.body ?? [])
                    let elements = try [JSON].deserialize(json["clones"])
                    var clones: [GitHub.Repository.Traffic.Clones.Clone] = []
                    clones.reserveCapacity(elements.count)
                    for element in elements {
                        clones.append(
                            try .init(
                                timestamp: Self.timestamp(element["timestamp"]),
                                count: Self.nonnegative(
                                    element["count"], expected: "nonnegative clone count"
                                ),
                                uniques: Self.nonnegative(
                                    element["uniques"],
                                    expected: "nonnegative unique clone count"
                                )
                            )
                        )
                    }
                    return try .init(
                        count: Self.nonnegative(json["count"], expected: "nonnegative clone count"),
                        uniques: Self.nonnegative(
                            json["uniques"], expected: "nonnegative unique clone count"
                        ),
                        clones: clones
                    )
                } catch {
                    throw .json(error)
                }
            },
            paths: { request async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) in
                let httpRequest = try self.request(
                    path: [
                        // swift-linter:disable:next raw value access
                        // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                        "repos", request.owner.rawValue, request.repository.rawValue,
                        "traffic", "popular", "paths",
                    ],
                    authentication: authentication
                )
                let httpResponse = try await self.response(for: httpRequest)

                do throws(JSON.Error) {
                    let elements = try [JSON].deserialize(
                        JSON.parse(httpResponse.body ?? [])
                    )
                    var paths: [GitHub.Repository.Traffic.Paths.Path] = []
                    paths.reserveCapacity(elements.count)
                    for element in elements {
                        paths.append(
                            try .init(
                                path: String.deserialize(element["path"]),
                                title: String.deserialize(element["title"]),
                                count: Self.nonnegative(
                                    element["count"], expected: "nonnegative path count"
                                ),
                                uniques: Self.nonnegative(
                                    element["uniques"], expected: "nonnegative unique path count"
                                )
                            )
                        )
                    }
                    return .init(paths: paths)
                } catch {
                    throw .json(error)
                }
            },
            referrers: { request async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) in
                let httpRequest = try self.request(
                    path: [
                        // swift-linter:disable:next raw value access
                        // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                        "repos", request.owner.rawValue, request.repository.rawValue,
                        "traffic", "popular", "referrers",
                    ],
                    authentication: authentication
                )
                let httpResponse = try await self.response(for: httpRequest)

                do throws(JSON.Error) {
                    let elements = try [JSON].deserialize(
                        JSON.parse(httpResponse.body ?? [])
                    )
                    var referrers: [GitHub.Repository.Traffic.Referrers.Referrer] = []
                    referrers.reserveCapacity(elements.count)
                    for element in elements {
                        referrers.append(
                            try .init(
                                referrer: String.deserialize(element["referrer"]),
                                count: Self.nonnegative(
                                    element["count"], expected: "nonnegative referrer count"
                                ),
                                uniques: Self.nonnegative(
                                    element["uniques"],
                                    expected: "nonnegative unique referrer count"
                                )
                            )
                        )
                    }
                    return .init(referrers: referrers)
                } catch {
                    throw .json(error)
                }
            }
        )
    }
}
