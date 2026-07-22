extension GitHub.HTTP {
    public enum Authentication: Equatable, Hashable, Sendable {
        case none
        case token(Token)
    }
}
