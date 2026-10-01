#if Calendar
import Testing
import Calendar_Gregorian
import Version

@Suite struct `Version.Calendar Tests` {
    @Test
    func `Calendar cases retain their components`() throws {
        let month = try Gregorian.Month(5)
        let version = Version.Calendar.full(
            year: Gregorian.Year(2026),
            month: month,
            micro: 13,
            modifier: "rc1"
        )
        #expect(version.description == "2026.05.13-rc1")
    }

    @Test
    func `Modifier-bearing calendar versions sort before releases`() throws {
        let month = try Gregorian.Month(5)
        let prerelease = Version.Calendar.full(
            year: Gregorian.Year(2026), month: month, micro: 13, modifier: "rc1"
        )
        let release = Version.Calendar.full(
            year: Gregorian.Year(2026), month: month, micro: 13
        )
        #expect(prerelease < release)
    }
}


extension `Version.Calendar Tests` {
    @Test func fullUnsignedMicroRangeSupportsFormattingAndOrdering() throws {
        let month = try Gregorian.Month(9)
        let maximum = Version.Calendar.full(year: 2026, month: month, micro: .init(UInt.max))
        let previous = Version.Calendar.full(year: 2026, month: month, micro: .init(UInt.max - 1))
        #expect(previous < maximum)
        #expect(maximum.description == "2026.09.\(UInt.max)")
        #expect(maximum.debugDescription == ".full(year: 2026, month: 9, micro: \(UInt.max), modifier: nil)")
    }

    @Test func orderingDistinguishesPrecisionAndAgreesWithEquality() throws {
        let month = try Gregorian.Month(9)
        let values: [Version.Calendar] = [
            .yearOnly(year: -1), .yearOnly(year: 2026),
            .yearMonth(year: 2026, month: month),
            .full(year: 2026, month: month, micro: 0, modifier: "rc1"),
            .full(year: 2026, month: month, micro: 0),
            .full(year: 2026, month: month, micro: 1)
        ]
        for (i, lhs) in values.enumerated() {
            for (j, rhs) in values.enumerated() {
                #expect((lhs < rhs) == (i < j))
                #expect((lhs == rhs) == (i == j))
                #expect((!(lhs < rhs) && !(rhs < lhs)) == (lhs == rhs))
            }
        }
    }
}
#endif
