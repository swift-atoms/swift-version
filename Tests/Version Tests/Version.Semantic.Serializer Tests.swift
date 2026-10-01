#if Parser && Serializer
import Version
import Byte
import Parser
import Serializer
import Testing
import Tagged

@Suite struct `Version.Semantic.Serializer Tests` {
    @Test
    func `Serializes a bare version to bytes`() {
        let version = Version.Semantic(major: 1, minor: 2, patch: 3)
        var buffer: [Byte] = []
        Version.Semantic.Serializer().serialize(version, into: &buffer)
        #expect(Swift.String(decoding: buffer.map(\.bitPattern), as: Swift.UTF8.self) == "1.2.3")
    }

    @Test
    func `Serializes with prerelease and build metadata`() {
        let version = Version.Semantic(
            major: 1,
            minor: 2,
            patch: 3,
            preReleaseIdentifiers: [.alphanumeric("alpha"), .numeric(1)],
            buildMetadataIdentifiers: ["sha", "abc123"]
        )
        var buffer: [Byte] = []
        Version.Semantic.Serializer().serialize(version, into: &buffer)
        #expect(Swift.String(decoding: buffer.map(\.bitPattern), as: Swift.UTF8.self) == "1.2.3-alpha.1+sha.abc123")
    }

    @Test
    func `Parser and Serializer round-trip`() throws(Version.Semantic.ParserError) {
        let inputs = [
            "0.0.0",
            "1.0.0",
            "1.2.3",
            "1.2.3-alpha",
            "1.2.3-alpha.1",
            "1.2.3-0.3.7",
            "1.2.3-x.7.z.92",
            "1.2.3+sha.abc",
            "1.2.3-rc.1+build.456",
            "10.20.30",
        ]
        for input in inputs {
            var bytes = [Byte](utf8: input)[...]
            let parsed = try Version.Semantic.Parser().parse(&bytes)
            var buffer: [Byte] = []
            Version.Semantic.Serializer().serialize(parsed, into: &buffer)
            let roundTripped = Swift.String(decoding: buffer.map(\.bitPattern), as: Swift.UTF8.self)
            #expect(roundTripped == input, "round-trip failure for \(input)")
        }
    }

    @Test
    func `Serializer emits the complete semantic representation`() {
        let version = Version.Semantic(
            major: 2,
            minor: 0,
            patch: 0,
            preReleaseIdentifiers: [.alphanumeric("rc"), .numeric(1)],
            buildMetadataIdentifiers: ["build", "99"]
        )
        var buffer: [Byte] = []
        Version.Semantic.Serializer().serialize(version, into: &buffer)
        #expect(Swift.String(decoding: buffer.map(\.bitPattern), as: Swift.UTF8.self) == "2.0.0-rc.1+build.99")
    }
}
#endif
