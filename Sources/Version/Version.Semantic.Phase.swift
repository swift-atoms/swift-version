extension Version.Semantic {

    public enum Phase: Swift::Sendable, Swift::Hashable {

        case initial

        case stable
    }

    @inlinable
    public var phase: Phase {
        self.major.underlying == 0 ? .initial : .stable
    }
}

extension Version.Semantic.Phase: Swift::CustomDebugStringConvertible {

    @inlinable
    public var debugDescription: Swift::String {
        switch self {
        case .initial: return ".initial"
        case .stable: return ".stable"
        }
    }
}

extension Version.Semantic.Phase: Swift::CustomStringConvertible {

    @inlinable
    public var description: Swift::String {
        switch self {
        case .initial: return "initial"
        case .stable: return "stable"
        }
    }
}
