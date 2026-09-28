#if Calendar
import Testing
import Version

@Suite struct VersionCalendarDescriptionTests {
    @Test
    func `Year-only debug retains case label`() {
        let v = Version.Calendar.yearOnly(year: Gregorian.Year(2026))
        #expect(v.debugDescription == ".yearOnly(year: 2026, modifier: nil)")
    }

    @Test
    func `Year-month debug retains case label`() throws {
        let v = Version.Calendar.yearMonth(year: Gregorian.Year(2026), month: try Gregorian.Month(5))
        #expect(v.debugDescription == ".yearMonth(year: 2026, month: 5, modifier: nil)")
    }

    @Test
    func `Full debug retains case label`() throws {
        let v = Version.Calendar.full(
            year: Gregorian.Year(2026), month: try Gregorian.Month(5), micro: 13
        )
        #expect(v.debugDescription == ".full(year: 2026, month: 5, micro: 13, modifier: nil)")
    }

    @Test
    func `Modifier round-trips through debug as quoted string`() throws {
        let v = Version.Calendar.full(
            year: Gregorian.Year(2026), month: try Gregorian.Month(5), micro: 13, modifier: "rc1"
        )
        #expect(v.debugDescription == ".full(year: 2026, month: 5, micro: 13, modifier: \"rc1\")")
    }

    @Test
    func `Debug distinguishes scheme identity that description erases`() throws {
        let month = try Gregorian.Month(5)
        let yearMonth = Version.Calendar.yearMonth(year: Gregorian.Year(2026), month: month)
        let full = Version.Calendar.full(year: Gregorian.Year(2026), month: month, micro: 0)
        #expect(yearMonth.debugDescription != full.debugDescription)
    }
}


extension VersionCalendarDescriptionTests {
    @Test func debugEscapesQuotedAndMultilineModifiers() {
        let version = Version.Calendar.yearOnly(year: 2026, modifier: "a\"b\nc")
        #expect(version.debugDescription == ".yearOnly(year: 2026, modifier: \"a\\\"b\\nc\")")
    }
}
#endif
