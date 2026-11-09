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
            func `Overflowing numeric prerelease reports its byte range`() {
                let digits = "\(UInt.max)0"
                var input = [Byte](utf8: "1.0.0-" + digits)[...]
                do {
                    _ = try Version.Semantic.Parser().parse(&input)
                    Issue.record("expected throw")
                } catch let error {
                    #expect(error.range.start.underlying.rawValue == 6)
                    #expect(error.range.end.underlying.rawValue == UInt(6 + digits.utf8.count))
                }
            }

            @Test
            func `A non-SemVer byte ends the prerelease and is left unconsumed`() throws {
                var input = [Byte](utf8: "1.0.0-alpha!")[...]
                let value = try Version.Semantic.Parser().parse(&input)
                #expect(value.preReleaseIdentifiers == [.alphanumeric("alpha")])
                #expect(input.map(\.bitPattern) == Array("!".utf8))
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
