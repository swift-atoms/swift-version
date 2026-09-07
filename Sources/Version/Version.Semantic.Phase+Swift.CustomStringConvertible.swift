extension Version.Semantic.Phase: Swift.CustomStringConvertible {

    @inlinable
    public var description: Swift.String {
        switch self {
        case .initial: return "initial"
        case .stable: return "stable"
        }
    }
}
