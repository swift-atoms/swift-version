public import Tagged

extension Version.Range where Underlying == Version.Semantic {

    @inlinable
    public static func upToNextMajor(from version: Version.Semantic) -> Self {
        let nextMajor = Version.Semantic(
            major: .init(_unchecked: version.major.underlying + 1),
            minor: .init(_unchecked: 0),
            patch: .init(_unchecked: 0)
        )
        return Self(lowerBound: .inclusive(version), upperBound: .exclusive(nextMajor))
    }

    @inlinable
    public static func upToNextMinor(from version: Version.Semantic) -> Self {
        let nextMinor = Version.Semantic(
            major: version.major,
            minor: .init(_unchecked: version.minor.underlying + 1),
            patch: .init(_unchecked: 0)
        )
        return Self(lowerBound: .inclusive(version), upperBound: .exclusive(nextMinor))
    }
}
