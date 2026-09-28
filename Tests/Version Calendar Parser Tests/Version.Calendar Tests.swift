#if Parser && Calendar
import Version
import Tagged
import Testing
import Calendar_Gregorian

extension Version.Calendar {
    @Suite struct `Calendar version` {
        @Suite struct `Construction` {}
        @Suite struct `Comparison` {}
        @Suite struct `Round trip` {}
        @Suite struct `Error cases` {}
    }
}

extension Version.Calendar.`Calendar version`.`Construction` {
    @Test
    func `Parses year-only`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026")
        guard case .yearOnly(let year, let modifier) = v else {
            Issue.record("expected yearOnly case")
            return
        }
        #expect(year.rawValue == 2026)
        #expect(modifier == nil)
    }

    @Test
    func `Parses year-month`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "24.04")
        guard case .yearMonth(let year, let month, _) = v else {
            Issue.record("expected yearMonth case")
            return
        }
        #expect(year.rawValue == 24)
        #expect(month.rawValue == 4)
    }

    @Test
    func `Parses full form`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026.05.13")
        guard case .full(let year, let month, let micro, _) = v else {
            Issue.record("expected full case")
            return
        }
        #expect(year.rawValue == 2026)
        #expect(month.rawValue == 5)
        #expect(micro.underlying == 13)
    }

    @Test
    func `Parses with modifier`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026.05.13-rc1")
        guard case .full(_, _, _, let modifier) = v else {
            Issue.record("expected full case")
            return
        }
        #expect(modifier == "rc1")
    }
}

extension Version.Calendar.`Calendar version`.`Comparison` {
    @Test
    func `Newer year is greater`() throws(Version.Calendar.Error) {
        let a = try Version.Calendar(parsing: "2025.12")
        let b = try Version.Calendar(parsing: "2026.01")
        #expect(a < b)
    }

    @Test
    func `Modifier-bearing orders lower than modifier-free`() throws(Version.Calendar.Error) {
        let pre = try Version.Calendar(parsing: "2026.05.13-rc1")
        let release = try Version.Calendar(parsing: "2026.05.13")
        #expect(pre < release)
    }

    @Test
    func `Precision breaks numeric ties`() throws(Version.Calendar.Error) {
        let yearMonth = try Version.Calendar(parsing: "2026.05")
        let full = try Version.Calendar(parsing: "2026.05.0")

        #expect(yearMonth < full)
        #expect(!(full < yearMonth))

        #expect(yearMonth != full)
    }
}

extension Version.Calendar.`Calendar version`.`Round trip` {
    @Test
    func `Year-only round-trips`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026")
        #expect(v.description == "2026")
    }

    @Test
    func `Full form with modifier round-trips`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026.05.13-rc1")
        #expect(v.description == "2026.05.13-rc1")
    }
}

extension Version.Calendar.`Calendar version`.`Error cases` {
    @Test
    func `Empty rejected`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "")
        }
    }

    @Test
    func `Non-numeric rejected`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "abc")
        }
    }

    @Test
    func `Empty modifier rejected`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "2026.05.13-")
        }
    }

    @Test
    func `Four numeric components rejected`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "2026.05.13.99")
        }
    }

    @Test
    func `Month out of range (>12) rejected via Gregorian.Month validation`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "2026.13.01")
        }
    }

    @Test
    func `Month zero rejected via Gregorian.Month validation`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "2026.00.01")
        }
    }
}


extension Version.Calendar.`Calendar version`.`Error cases` {
    @Test(arguments: [
        "\(UInt.max)", "\(UInt(Int.max) + 1)", "2026.\(UInt.max)",
        "2026.09.\(UInt.max)0"
    ])
    func numericFieldsRejectOverflowWithoutTrapping(_ input: String) {
        #expect(throws: Version.Calendar.Error.self) { try Version.Calendar(parsing: input) }
    }

    @Test(arguments: ["-1", "2026.09-rélease", "2026.09-"])
    func restrictedGrammarRejectsValuesOutsideItsWireDomain(_ input: String) {
        #expect(throws: Version.Calendar.Error.self) { try Version.Calendar(parsing: input) }
    }
}

extension Version.Calendar.`Calendar version`.`Construction` {
    @Test func numericBoundariesKeepTheOwnersFullSupportedRanges() throws {
        let input = "\(Int.max).09.\(UInt.max)"
        let value = try Version.Calendar(parsing: input)
        guard case .full(let year, let month, let micro, _) = value else {
            Issue.record("Expected full calendar version")
            return
        }
        #expect(year.rawValue == Int.max)
        #expect(month.rawValue == 9)
        #expect(micro.underlying == UInt.max)
        #expect(value.description == input)
    }
}
#endif
