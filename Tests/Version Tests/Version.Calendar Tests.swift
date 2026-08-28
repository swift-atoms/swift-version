import Testing
import Time
import Version

@Suite struct `Version.Calendar Tests` {
    @Test
    func `Calendar cases retain their components`() throws {
        let month = try Time.Month(5)
        let version = Version.Calendar.full(
            year: Time.Year(2026),
            month: month,
            micro: 13,
            modifier: "rc1"
        )
        #expect(version.description == "2026.05.13-rc1")
    }

    @Test
    func `Modifier-bearing calendar versions sort before releases`() throws {
        let month = try Time.Month(5)
        let prerelease = Version.Calendar.full(
            year: Time.Year(2026), month: month, micro: 13, modifier: "rc1"
        )
        let release = Version.Calendar.full(
            year: Time.Year(2026), month: month, micro: 13
        )
        #expect(prerelease < release)
    }
}
