#if Serializer && Calendar
import Byte
import Version
import Serializer
import Testing

@Suite struct `Version Serializer Tests` {
    @Test
    func `Semantic serializer emits canonical bytes`() {
        let version = Version.Semantic(
            major: 1,
            minor: 2,
            patch: 3,
            preReleaseIdentifiers: [.alphanumeric("rc"), .numeric(1)],
            buildMetadataIdentifiers: ["build", "42"]
        )
        var bytes: [Byte] = []
        Version.Semantic.Serializer().serialize(version, into: &bytes)
        #expect(Swift.String(decoding: bytes.map(\.bitPattern), as: Swift.UTF8.self) == "1.2.3-rc.1+build.42")
    }

    @Test
    func `Tools serializer preserves omitted patch`() {
        let version = Version.Tools(major: 6, minor: 4)
        var bytes: [Byte] = []
        Version.Tools.Serializer().serialize(version, into: &bytes)
        #expect(Swift.String(decoding: bytes.map(\.bitPattern), as: Swift.UTF8.self) == "6.4")
    }
}


extension `Version Serializer Tests` {
    @Test func calendarSerializerAppendsCanonicalUTF8WithoutReplacingPrefix() throws {
        let value = Version.Calendar.full(
            year: -1, month: try Gregorian.Month(9), micro: .init(UInt.max), modifier: "rélease"
        )
        var bytes = [Byte(bitPattern: 0x7C)]
        Version.Calendar.Serializer().serialize(value, into: &bytes)
        #expect(bytes.map(\.bitPattern) == Array("|-1.09.\(UInt.max)-rélease".utf8))
        Version.Calendar.Serializer().serialize(.yearOnly(year: 2026), into: &bytes)
        #expect(bytes.map(\.bitPattern) == Array("|-1.09.\(UInt.max)-rélease2026".utf8))
    }

    @Test func toolsSerializerDistinguishesOmittedAndExplicitZeroPatch() {
        var bytes: [Byte] = []
        Version.Tools.Serializer().serialize(.init(major: 6, minor: 4, patch: 0), into: &bytes)
        #expect(bytes.map(\.bitPattern) == Array("6.4.0".utf8))
    }
}
#endif
