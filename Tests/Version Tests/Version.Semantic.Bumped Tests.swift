import Tagged
import Testing
import Version

extension Version.Semantic.Bumped {
    @Suite struct Test {
        @Test
        func `Major bump zeros minor and patch`() {
            let v = Version.Semantic(major: 1, minor: 2, patch: 3)
            let bumped = v.bumped.major
            #expect(bumped.major.underlying == 2)
            #expect(bumped.minor.underlying == 0)
            #expect(bumped.patch.underlying == 0)
        }

        @Test
        func `Minor bump zeros patch, preserves major`() {
            let v = Version.Semantic(major: 1, minor: 2, patch: 3)
            let bumped = v.bumped.minor
            #expect(bumped.major.underlying == 1)
            #expect(bumped.minor.underlying == 3)
            #expect(bumped.patch.underlying == 0)
        }

        @Test
        func `Patch bump preserves major and minor`() {
            let v = Version.Semantic(major: 1, minor: 2, patch: 3)
            let bumped = v.bumped.patch
            #expect(bumped.major.underlying == 1)
            #expect(bumped.minor.underlying == 2)
            #expect(bumped.patch.underlying == 4)
        }

        @Test
        func `Bumping drops pre-release and build metadata`() {
            let v = Version.Semantic(
                major: 1,
                minor: 2,
                patch: 3,
                preReleaseIdentifiers: [.alphanumeric("rc"), .numeric(1)],
                buildMetadataIdentifiers: ["build", "42"]
            )
            let bumped = v.bumped.patch
            #expect(bumped.preReleaseIdentifiers.isEmpty)
            #expect(bumped.buildMetadataIdentifiers.isEmpty)
            #expect(bumped.patch.underlying == 4)
        }

        @Test
        func `Bumping is total ordering: bumped > self`() {
            let v = Version.Semantic(major: 1, minor: 2, patch: 3)
            #expect(v.bumped.patch > v)
            #expect(v.bumped.minor > v.bumped.patch)
            #expect(v.bumped.major > v.bumped.minor)
        }
    }
}
