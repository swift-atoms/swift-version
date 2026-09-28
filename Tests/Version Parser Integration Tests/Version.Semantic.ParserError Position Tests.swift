#if Parser && Serializer
import Byte
import Ordinal
import Testing
import Text
import Version

extension Version.Semantic.ParserError {
    @Suite struct Test {

        @Test
        func `Leading zero in MAJOR reports the digit-run range`() {
            var input = [Byte](utf8: "01.0.0")[...]
            do {
                _ = try Version.Semantic.Parser().parse(&input)
                Issue.record("expected throw")
            } catch let error {
                #expect(error.range.start.underlying.rawValue == 0)
                #expect(error.range.end.underlying.rawValue == 2)
            }
        }

        @Test
        func `Two-component core reports range at end of input`() {
            var input = [Byte](utf8: "1.2")[...]
            do {
                _ = try Version.Semantic.Parser().parse(&input)
                Issue.record("expected throw")
            } catch let error {
                #expect(error.range.start.underlying.rawValue == 3)
                #expect(error.range.end.underlying.rawValue == 3)
            }
        }

        @Test
        func `Invalid prerelease bytes report their byte range`() {
            var input = [Byte](utf8: "1.0.0-alpha!")[...]
            do {
                _ = try Version.Semantic.Parser().parse(&input)
                Issue.record("expected throw")
            } catch let error {
                #expect(error.range.start.underlying.rawValue == 6)
                #expect(error.range.end.underlying.rawValue == 12)
            }
        }

        @Test
        func `Empty prerelease reports the dash-following position`() {
            var input = [Byte](utf8: "1.0.0-")[...]
            do {
                _ = try Version.Semantic.Parser().parse(&input)
                Issue.record("expected throw")
            } catch let error {
                #expect(error.range.start.underlying.rawValue == 6)
                #expect(error.range.end.underlying.rawValue == 6)
            }
        }
    }
}
#endif
