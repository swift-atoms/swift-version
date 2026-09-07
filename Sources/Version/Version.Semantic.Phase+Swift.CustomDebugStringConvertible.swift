extension Version.Semantic.Phase: Swift.CustomDebugStringConvertible {

    @inlinable
    public var debugDescription: Swift.String {
        switch self {
        case .initial: return ".initial"
        case .stable: return ".stable"
        }
    }
}
