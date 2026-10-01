#if Parser && Serializer
import Version
import Byte
import Serializer
import Tagged
import Testing

@Suite struct `Version.Tools Parser Tests` {

    @Test
    func `Parses two- and three-component tools versions`() throws(Version.Tools.ParserError) {
        var twoComponent = [Byte](utf8: "6.4")[...]
        let first = try Version.Tools.Parser().parse(&twoComponent)
        #expect(first.major.underlying == 6)
        #expect(first.minor.underlying == 4)
        #expect(first.patch == nil)

        var threeComponent = [Byte](utf8: "6.4.1")[...]
        let second = try Version.Tools.Parser().parse(&threeComponent)
        #expect(second.patch?.underlying == 1)
    }

    @Test
    func `Serializer round-trips tools versions`() throws(Version.Tools.ParserError) {
        var input = [Byte](utf8: "6.4.1")[...]
        let version = try Version.Tools.Parser().parse(&input)
        var output: [Byte] = []
        Version.Tools.Serializer().serialize(version, into: &output)
        #expect(Swift.String(decoding: output.map(\.bitPattern), as: Swift.UTF8.self) == "6.4.1")
    }

    @Test
    func `Default parser uses byte input`() throws(Version.Tools.ParserError) {
        var input = [Byte](utf8: "6.4")[...]
        let version = try Version.Tools.parser.parse(&input)
        #expect(version.major.underlying == 6)
        #expect(version.minor.underlying == 4)
    }
}
#endif
