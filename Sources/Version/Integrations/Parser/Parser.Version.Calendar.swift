#if Parser && Calendar

internal import Byte
internal import Cursor
public import Ordinal
internal import Parser
public import Text

extension Version.Calendar {

    public init(parsing calverString: Swift.String) throws(Version.Calendar.Error) {
        let totalBytes = Swift.UInt(calverString.utf8.count)
        for (offset, byte) in calverString.utf8.enumerated() where byte >= 0x80 {
            let position = Self.position(Swift.UInt(offset))
            throw .nonASCIICharacters(
                input: calverString,
                range: Text.Range(start: position, end: Self.position(Swift.UInt(offset) + 1))
            )
        }
        var input = [Byte](utf8: calverString)[...]
        self = try Version.Calendar.Parser().parse(&input)
        if !input.isEmpty {
            let remaining = Swift.UInt(input.count)
            let consumed = totalBytes - remaining
            let trailing = Swift.String(decoding: input.map(\.bitPattern), as: Swift.UTF8.self)
            throw .invalidCalendarIdentifier(
                input: calverString,
                identifier: trailing,
                range: Text.Range(
                    start: Self.position(consumed),
                    end: Self.position(totalBytes)
                )
            )
        }
    }

    @inlinable
    package static func position(_ offset: Swift.UInt) -> Text.Position {
        Text.Position(_unchecked: Ordinal(offset))
    }
}
#endif
