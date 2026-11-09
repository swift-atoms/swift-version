extension Version.Semantic {

    public struct Bumped: Swift::Sendable {
        @usableFromInline
        let base: Version.Semantic

        @inlinable
        package init(_ base: Version.Semantic) {
            self.base = base
        }
    }

    @inlinable
    public var bumped: Bumped {
        Bumped(self)
    }
}

extension Version.Semantic.Bumped {

    /// The next major version. Bumping a major at `Swift.UInt.max` is a programmer error and traps.
    @inlinable
    public var major: Version.Semantic {
        precondition(self.base.major.underlying < Swift::UInt.max, "major is at Swift.UInt.max and cannot be bumped")
        return Version.Semantic(
            major: .init(self.base.major.underlying + 1),
            minor: 0,
            patch: 0
        )
    }

    /// The next minor version. Bumping a minor at `Swift.UInt.max` is a programmer error and traps.
    @inlinable
    public var minor: Version.Semantic {
        precondition(self.base.minor.underlying < Swift::UInt.max, "minor is at Swift.UInt.max and cannot be bumped")
        return Version.Semantic(
            major: self.base.major,
            minor: .init(self.base.minor.underlying + 1),
            patch: 0
        )
    }

    /// The next patch version. Bumping a patch at `Swift.UInt.max` is a programmer error and traps.
    @inlinable
    public var patch: Version.Semantic {
        precondition(self.base.patch.underlying < Swift::UInt.max, "patch is at Swift.UInt.max and cannot be bumped")
        return Version.Semantic(
            major: self.base.major,
            minor: self.base.minor,
            patch: .init(self.base.patch.underlying + 1)
        )
    }
}
