import GitHub
import GitHub_Standard
import JSON

extension GitHub.HTTP.Client {
    public func repository(
        authentication: GitHub.HTTP.Authentication
    ) -> GitHub.Repository.Get.Client<
        GitHub.HTTP.Error<ExecutionFailure, Never>
    > {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) in
            let httpRequest = try self.request(
                // swift-linter:disable:next raw value access
                // REASON: wire-boundary extraction into HTTP request/response components (GitHub HTTP adapter; ruling class 3, [PATTERN-017] boundary use).
                path: ["repos", request.owner.underlying, request.repository.underlying],
                authentication: authentication
            )
            let httpResponse = try await self.response(for: httpRequest)

            do throws(JSON.Error) {
                return try .init(
                    repository: Self.metadata(
                        from: JSON.parse(httpResponse.body ?? [])
                    )
                )
            } catch {
                throw .json(error)
            }
        }
    }
}
