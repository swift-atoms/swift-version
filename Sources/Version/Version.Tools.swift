public import Tagged

extension Version {

    public struct Tools: Swift.Sendable, Swift.Hashable, Swift.Comparable, Swift
            .CustomStringConvertible
    {

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

    }
}

extension Version.Tools {

    public var description: Swift.String {
        var value = "\(major.underlying).\(minor.underlying)"
        if let patch {
            value += ".\(patch.underlying)"
        }
        return value
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Swift.Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        let lp = lhs.patch?.underlying ?? 0
        let rp = rhs.patch?.underlying ?? 0
        return lp < rp
    }

}
