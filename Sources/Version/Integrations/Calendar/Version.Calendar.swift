#if Calendar
    public import Tagged
    public import Calendar_Gregorian

    extension Version {

        public enum Calendar: Swift::Sendable, Swift::Hashable, Swift::Comparable, Swift::CustomStringConvertible {

            case yearOnly(year: Gregorian.Year, modifier: Swift::String? = nil)

            case yearMonth(year: Gregorian.Year, month: Gregorian.Month, modifier: Swift::String? = nil)

            case full(
                year: Gregorian.Year,
                month: Gregorian.Month,
                micro: Micro.Value,
                modifier: Swift::String? = nil
            )

        }
    }

    extension Version.Calendar {

        public var description: Swift::String {
            func padded(_ value: Swift::UInt) -> Swift::String {
                value < 10 ? "0\(value)" : Swift::String(value)
            }
            func suffixed(_ value: Swift::String, _ modifier: Swift::String?) -> Swift::String {
                modifier.map { value + "-" + $0 } ?? value
            }
            switch self {
            case .yearOnly(let year, let modifier):
                return suffixed(Swift::String(year.rawValue), modifier)
            case .yearMonth(let year, let month, let modifier):
                return suffixed("\(year.rawValue).\(padded(Swift::UInt(month.rawValue)))", modifier)
            case .full(let year, let month, let micro, let modifier):
                return suffixed(
                    "\(year.rawValue).\(padded(Swift::UInt(month.rawValue))).\(padded(micro.underlying))",
                    modifier
                )
            }
        }

        public static func < (lhs: Self, rhs: Self) -> Swift::Bool {
            let (ly, lm, lu, lp, lmod) = lhs.normalized()
            let (ry, rm, ru, rp, rmod) = rhs.normalized()
            if ly != ry { return ly < ry }
            if lm != rm { return lm < rm }
            if lu != ru { return lu < ru }
            if lp != rp { return lp < rp }
            switch (lmod, rmod) {
            case (nil, nil): return false
            case (nil, _?): return false
            case (_?, nil): return true
            case (let l?, let r?): return l < r
            }
        }

        @usableFromInline
        func normalized() -> (
            year: Swift::Int, month: Swift::Int, micro: Swift::UInt, precision: Swift::Int, modifier: Swift::String?
        ) {
            switch self {
            case .yearOnly(let y, let mod):
                return (y.rawValue, 0, 0, 0, mod)

            case .yearMonth(let y, let m, let mod):
                return (y.rawValue, m.rawValue, 0, 1, mod)

            case .full(let y, let m, let micro, let mod):
                return (y.rawValue, m.rawValue, micro.underlying, 2, mod)
            }
        }

    }
#endif

#if Calendar
    internal import Calendar_Gregorian

    extension Version.Calendar: Swift::CustomDebugStringConvertible {

        public var debugDescription: Swift::String {
            switch self {
            case .yearOnly(let year, let modifier):
                return ".yearOnly(year: " + Self.format(year.rawValue)
                    + ", modifier: " + Self.format(modifier) + ")"

            case .yearMonth(let year, let month, let modifier):
                return ".yearMonth(year: " + Self.format(year.rawValue)
                    + ", month: " + Self.format(month.rawValue)
                    + ", modifier: " + Self.format(modifier) + ")"

            case .full(let year, let month, let micro, let modifier):
                return ".full(year: " + Self.format(year.rawValue)
                    + ", month: " + Self.format(month.rawValue)
                    + ", micro: " + Swift::String(micro.underlying)
                    + ", modifier: " + Self.format(modifier) + ")"
            }
        }

        @usableFromInline
        static func format(_ value: Swift::Int) -> Swift::String {
            Swift::String(value)
        }

        @usableFromInline
        static func format(_ modifier: Swift::String?) -> Swift::String {
            switch modifier {
            case .none: return "nil"
            case .some(let value): return Swift::String(reflecting: value)
            }
        }
    }
#endif

#if Parser && Calendar

    internal import Byte
    internal import Cursor
    public import Ordinal
    internal import Parser
    public import Text

    extension Version.Calendar {

        public init(parsing calverString: Swift::String) throws(Version.Calendar.Error) {
            let totalBytes = Swift::UInt(calverString.utf8.count)
            for (offset, byte) in calverString.utf8.enumerated() where byte >= 0x80 {
                let position = Self.position(Swift::UInt(offset))
                throw .nonASCIICharacters(
                    input: calverString,
                    range: Text.Range(start: position, end: Self.position(Swift::UInt(offset) + 1))
                )
            }
            var input = [Byte](utf8: calverString)[...]
            self = try Version.Calendar.Parser().parse(&input)
            if !input.isEmpty {
                let remaining = Swift::UInt(input.count)
                let consumed = totalBytes - remaining
                let trailing = Swift::String(decoding: input.map(\.bitPattern), as: Swift::UTF8.self)
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
        package static func position(_ offset: Swift::UInt) -> Text.Position {
            Text.Position(_unchecked: Ordinal(offset))
        }
    }
#endif

#if Parser && Calendar

    public import Byte
    public import Cursor
    import Parser

    extension Version.Calendar {

        @inlinable
        public static var parser: Version.Calendar.Parser<ArraySlice<Byte>> { Version.Calendar.Parser<ArraySlice<Byte>>() }
    }
#endif
