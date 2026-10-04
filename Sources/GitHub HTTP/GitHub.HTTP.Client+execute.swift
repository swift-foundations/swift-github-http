import GitHub
import HTTP
import HTTP_Router
import RFC_9110

extension GitHub.HTTP.Client {
    func response(
        for request: HTTP.Router.Request
    ) async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) -> HTTP.Router.Response {
        let response: HTTP.Router.Response
        do throws(ExecutionFailure) {
            response = try await self.execute(request)
        } catch {
            throw .execute(error)
        }

        guard response.status.isSuccessful else {
            throw .status(response.status)
        }
        return response
    }
}
