public import Tagged

extension Version {

    public struct Tools: Swift.Sendable, Swift.Hashable, Swift.Comparable {

        public let major: Major.Value

        public let minor: Minor.Value

        public let patch: Patch.Value?

        @inlinable
        public init(
            major: Major.Value,
            minor: Minor.Value,
            patch: Patch.Value? = nil
        ) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        @_disfavoredOverload
        @inlinable
        public init(
            major: Swift.UInt,
            minor: Swift.UInt,
            patch: Swift.UInt? = nil
        ) {
            self.init(
                major: .init(_unchecked: major),
                minor: .init(_unchecked: minor),
                patch: patch.map { .init(_unchecked: $0) }
            )
        }
    }
}

extension Version.Tools {

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Swift.Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        let lp = lhs.patch?.underlying ?? 0
        let rp = rhs.patch?.underlying ?? 0
        return lp < rp
    }
}
