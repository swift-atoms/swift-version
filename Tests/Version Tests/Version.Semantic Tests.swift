import Testing
import Version

@Suite struct `Version.Semantic Tests` {
    @Test
    func `Component initializer retains the semantic representation`() {
        let version = Version.Semantic(
            major: 1,
            minor: 2,
            patch: 3,
            preReleaseIdentifiers: [.alphanumeric("rc"), .numeric(1)],
            buildMetadataIdentifiers: ["build", "42"]
        )
        #expect(version.description == "1.2.3-rc.1+build.42")
    }

    @Test
    func `Build metadata is excluded from semantic equality and hashing`() {
        let lhs = Version.Semantic(
            major: 1, minor: 0, patch: 0, buildMetadataIdentifiers: ["a"]
        )
        let rhs = Version.Semantic(
            major: 1, minor: 0, patch: 0, buildMetadataIdentifiers: ["b"]
        )
        #expect(lhs == rhs)
        #expect(lhs.hashValue == rhs.hashValue)
    }

    @Test
    func `Prerelease identifiers determine precedence`() {
        let prerelease = Version.Semantic(
            major: 1,
            minor: 0,
            patch: 0,
            preReleaseIdentifiers: [.alphanumeric("rc"), .numeric(1)]
        )
        let release = Version.Semantic(major: 1, minor: 0, patch: 0)
        #expect(prerelease < release)
    }
}
