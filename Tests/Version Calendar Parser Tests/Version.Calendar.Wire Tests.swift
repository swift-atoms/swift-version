#if Parser && Calendar
import Foundation
import Testing
import Version

extension Version.Calendar {
    @Suite struct `Explicit wire strings` {}
}

extension Version.Calendar.`Explicit wire strings` {

    @Test
    func `Encodes as its calendar-version string`() throws {
        let calendar = try Version.Calendar(parsing: "2026.05.13-rc1")
        let data = try JSONEncoder().encode(calendar.description)
        #expect(String(decoding: data, as: UTF8.self) == "\"2026.05.13-rc1\"")
    }

    @Test
    func `Round-trips through JSON`() throws {
        let calendar = try Version.Calendar(parsing: "2026.05")
        let data = try JSONEncoder().encode(calendar.description)
        #expect(try Version.Calendar(parsing: JSONDecoder().decode(String.self, from: data)) == calendar)
    }
}
#endif
