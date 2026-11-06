#if Parser

    import Byte
    import Parser

    extension Version.Semantic {

        /// The version `text` spells in full, or nil: `1.0` isn't semantic.
        public init?(parsing text: Swift::String) {
            var input = Swift::ArraySlice(text.utf8.map(Byte.init(bitPattern:)))
            do throws(Version.Semantic.ParserError) {
                let parsed = try Version.Semantic.parser.parse(&input)
                guard input.isEmpty else { return nil }
                self = parsed
            } catch {
                return nil
            }
        }
    }

    extension Version.Tools {

        /// The tools version `text` spells in full, such as `6.4` or `6.4.1`, or nil.
        public init?(parsing text: Swift::String) {
            var input = Swift::ArraySlice(text.utf8.map(Byte.init(bitPattern:)))
            do throws(Version.Tools.ParserError) {
                let parsed = try Version.Tools.parser.parse(&input)
                guard input.isEmpty else { return nil }
                self = parsed
            } catch {
                return nil
            }
        }
    }

#endif
