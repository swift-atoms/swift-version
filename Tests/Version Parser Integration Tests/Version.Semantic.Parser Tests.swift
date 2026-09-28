#if Parser && Serializer
import Version
import Byte
import Parser
import Testing
import Tagged
import Text

@Suite struct `Version.Semantic.Parser Tests` {
    @Test
    func `Parses a bare version from byte input`() throws(Version.Semantic.ParserError) {
        var input = [Byte](utf8: "1.2.3")[...]
        let version = try Version.Semantic.Parser().parse(&input)
        #expect(version.major.underlying == 1)
        #expect(version.minor.underlying == 2)
        #expect(version.patch.underlying == 3)
    }

    @Test
    func `Parses pre-release and build metadata from byte input`() throws(Version.Semantic.ParserError) {
        var input = [Byte](utf8: "1.2.3-alpha.1+sha.abc123")[...]
        let version = try Version.Semantic.Parser().parse(&input)
        #expect(version.preReleaseIdentifiers == [.alphanumeric("alpha"), .numeric(1)])
        #expect(version.buildMetadataIdentifiers == ["sha", "abc123"])
    }

    @Test
    func `Greedy consumption stops at non-version byte`() throws(Version.Semantic.ParserError) {
        var input = [Byte](utf8: "1.2.3 trailing")[...]
        let version = try Version.Semantic.Parser().parse(&input)
        #expect(version.major.underlying == 1)

        #expect(input.first?.bitPattern == 0x20)
    }

    @Test
    func `Invalid version syntax throws typed error`() {
        var input = [Byte](utf8: "1.2")[...]
        #expect(throws: Version.Semantic.ParserError.self) {
            _ = try Version.Semantic.Parser().parse(&input)
        }
    }

    @Test
    func `Empty input throws typed error`() {
        var input = [Byte](utf8: "")[...]
        #expect(throws: Version.Semantic.ParserError.self) {
            _ = try Version.Semantic.Parser().parse(&input)
        }
    }

    @Test
    func `Default parser uses byte input`() throws(Version.Semantic.ParserError) {
        var input = [Byte](utf8: "3.4.5")[...]
        let version = try Version.Semantic.parser.parse(&input)
        #expect(version.major.underlying == 3)
        #expect(version.minor.underlying == 4)
        #expect(version.patch.underlying == 5)
    }
}


extension `Version.Semantic.Parser Tests` {
    @Test func nonzeroSliceStartPreservesMaximumComponentsAndRemainder() throws {
        let storage = [Byte](utf8: "xx\(UInt.max).2.3 tail")
        var input = storage.dropFirst(2)
        let value = try Version.Semantic.Parser().parse(&input)
        #expect(value.major.underlying == UInt.max)
        #expect(input.map(\.bitPattern) == Array(" tail".utf8))
    }

    @Test func numericOverflowReportsTheWholeDigitRun() {
        let digits = "\(UInt.max)0"
        var input = [Byte](utf8: digits + ".2.3")[...]
        do {
            _ = try Version.Semantic.Parser().parse(&input)
            Issue.record("Expected overflow rejection")
        } catch {
            #expect(error.range.start.underlying.rawValue == 0)
            #expect(error.range.end.underlying.rawValue == UInt(digits.utf8.count))
        }
    }
}
#endif
