import Testing
import Version

extension Version.Semantic.Phase {
    @Suite struct Test {
        @Test
        func `Zero major is initial`() {
            let v = Version.Semantic(major: 0, minor: 1, patch: 0)
            #expect(v.phase == .initial)
        }

        @Test
        func `One major is stable`() {
            let v = Version.Semantic(major: 1, minor: 0, patch: 0)
            #expect(v.phase == .stable)
        }

        @Test
        func `Pre-release zero-major stays initial`() {
            let v = Version.Semantic(
                major: 0,
                minor: 9,
                patch: 0,
                preReleaseIdentifiers: [.alphanumeric("rc"), .numeric(1)]
            )
            #expect(v.phase == .initial)
        }

        @Test
        func `Major bump from zero crosses to stable`() {
            let initial = Version.Semantic(major: 0, minor: 99, patch: 99)
            #expect(initial.phase == .initial)
            #expect(initial.bumped.major.phase == .stable)
        }
    }
}
