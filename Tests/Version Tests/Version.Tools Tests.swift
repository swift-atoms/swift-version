import Testing
import Version

extension `Version.Tools Tests` {
    @Suite struct `Tools versions preserve omitted patches and compare present patches` {
        @Test
        func `Component initializer retains omitted patch`() {
            let version = Version.Tools(major: 6, minor: 4)
            #expect(version.patch == nil)
            #expect(version.description == "6.4")
        }

        @Test
        func `Patch participates in ordering`() {
            let lhs = Version.Tools(major: 6, minor: 4, patch: 0)
            let rhs = Version.Tools(major: 6, minor: 4, patch: 1)
            #expect(lhs < rhs)
        }

        @Test
        func `Omitted patch sorts before explicit zero patch`() {
            let short = Version.Tools(major: 6, minor: 4)
            let full = Version.Tools(major: 6, minor: 4, patch: 0)
            #expect(short != full)
            #expect(short < full)
            #expect(!(full < short))
        }

        @Test
        func `Ordering agrees with equality`() {
            let versions = [
                Version.Tools(major: 6, minor: 4),
                Version.Tools(major: 6, minor: 4, patch: 0),
                Version.Tools(major: 6, minor: 4, patch: 1),
                Version.Tools(major: 6, minor: 3, patch: 2),
            ]
            for lhs in versions {
                for rhs in versions {
                    let tied = !(lhs < rhs) && !(rhs < lhs)
                    #expect(tied == (lhs == rhs))
                }
            }
        }

        @Test
        func `Omitted patch still sorts after a lower patch`() {
            let short = Version.Tools(major: 6, minor: 4)
            let lower = Version.Tools(major: 6, minor: 3, patch: 9)
            let higher = Version.Tools(major: 6, minor: 4, patch: 1)
            #expect(lower < short)
            #expect(short < higher)
        }
    }
}
