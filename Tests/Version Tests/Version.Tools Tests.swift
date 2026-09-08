import Testing
import Version

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
}
