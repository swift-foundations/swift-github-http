import RFC_3986
import RFC_9110

extension RFC_9110.Target {
    var rawValue: String? {
        guard case .resource(let uri) = self else { return nil }
        return uri.value
    }
}

extension RFC_9110.Message.Headers {
    func first(_ name: String) -> RFC_9110.Field.Value? {
        guard let name = try? RFC_9110.Field.Name(name) else { return nil }
        return self[name].first
    }
}
