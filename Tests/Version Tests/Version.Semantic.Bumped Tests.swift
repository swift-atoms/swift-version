import Testing
import Version

enum `Version.Semantic.Bumped Tests` {}

extension `Version.Semantic.Bumped Tests` {
    @Suite struct `Semantic version bumps update components and discard prerelease metadata` {
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
            #expect(bumped.description == "1.2.4")
        }

        #if os(macOS) || os(Linux) || os(Windows)
            @Test
            func `Bumping a component at UInt.max traps`() async {
                await #expect(processExitsWith: .failure) {
                    _ = Version.Semantic(major: .init(.max), minor: 0, patch: 0).bumped.major
                }
                await #expect(processExitsWith: .failure) {
                    _ = Version.Semantic(major: 0, minor: .init(.max), patch: 0).bumped.minor
                }
                await #expect(processExitsWith: .failure) {
                    _ = Version.Semantic(major: 0, minor: 0, patch: .init(.max)).bumped.patch
                }
            }
        #endif

        @Test
        func `Bumping below UInt.max succeeds`() {
            let v = Version.Semantic(major: .init(.max - 1), minor: .init(.max - 1), patch: .init(.max - 1))
            #expect(v.bumped.patch.patch.underlying == .max)
            #expect(v.bumped.minor.minor.underlying == .max)
            #expect(v.bumped.major.major.underlying == .max)
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
