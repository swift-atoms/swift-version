public import Tagged

extension Version {

    public struct Semantic: Swift.Sendable, Swift.Hashable, Swift.Comparable {

        public let major: Major.Value

        public let minor: Minor.Value

        public let patch: Patch.Value

        public let preReleaseIdentifiers: [Identifier]

        public let buildMetadataIdentifiers: [Swift.String]

        public init(
            major: Major.Value,
            minor: Minor.Value,
            patch: Patch.Value,
            preReleaseIdentifiers: [Identifier] = [],
            buildMetadataIdentifiers: [Swift.String] = []
        ) {
            self.major = major
            self.minor = minor
            self.patch = patch
            self.preReleaseIdentifiers = preReleaseIdentifiers
            self.buildMetadataIdentifiers = buildMetadataIdentifiers
        }

        @_disfavoredOverload
        @inlinable
        public init(
            major: Swift.UInt,
            minor: Swift.UInt,
            patch: Swift.UInt,
            preReleaseIdentifiers: [Identifier] = [],
            buildMetadataIdentifiers: [Swift.String] = []
        ) {
            self.init(
                major: .init(_unchecked: major),
                minor: .init(_unchecked: minor),
                patch: .init(_unchecked: patch),
                preReleaseIdentifiers: preReleaseIdentifiers,
                buildMetadataIdentifiers: buildMetadataIdentifiers
            )
        }
    }
}

extension Version.Semantic {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.major == rhs.major
            && lhs.minor == rhs.minor
            && lhs.patch == rhs.patch
            && lhs.preReleaseIdentifiers == rhs.preReleaseIdentifiers
    }

    public func hash(into hasher: inout Swift.Hasher) {
        hasher.combine(self.major)
        hasher.combine(self.minor)
        hasher.combine(self.patch)
        hasher.combine(self.preReleaseIdentifiers)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }

        switch (lhs.preReleaseIdentifiers.isEmpty, rhs.preReleaseIdentifiers.isEmpty) {
        case (true, true): return false

        case (true, false): return false

        case (false, true): return true

        case (false, false):
            return Self.compareIdentifiers(lhs.preReleaseIdentifiers, rhs.preReleaseIdentifiers)
        }
    }

    private static func compareIdentifiers(_ lhs: [Identifier], _ rhs: [Identifier]) -> Bool {
        for (l, r) in zip(lhs, rhs) {
            if l == r { continue }
            return l < r
        }

        return lhs.count < rhs.count
    }
}
