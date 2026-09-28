#if Parser && Calendar

public import ASCII
public import Byte
public import Checkpoint
public import Cursor
public import Iterator
public import Parser
internal import Tagged
public import Text
internal import Calendar_Gregorian

extension Version.Calendar {

    public struct Parser<Input: Cursor.`Protocol`>
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension Version.Calendar.Parser: Parsing {

    public typealias Output = Version.Calendar

    public typealias Failure = Version.Calendar.Error

    public typealias Body = Never

    public func parse(_ input: inout Input) throws(Version.Calendar.Error) -> Version.Calendar {
        let originalString = Self.calendarString(in: &input)
        var offset: Swift.UInt = 0

        let yearValue = try Self.parseNumber(&input, offset: &offset, in: originalString)
        guard let rawYear = Swift.Int(exactly: yearValue) else {
            throw .invalidCalendarIdentifier(
                input: originalString, identifier: Swift.String(yearValue),
                range: Self.range(from: 0, to: offset)
            )
        }
        let year = Gregorian.Year(rawYear)

        var month: Gregorian.Month?
        var micro: Swift.UInt?

        if Self.consume(0x2E, from: &input) {
            offset += 1
            let monthStart = offset
            let monthValue = try Self.parseNumber(&input, offset: &offset, in: originalString)
            guard let rawMonth = Swift.Int(exactly: monthValue) else {
                throw .invalidCalendarIdentifier(
                    input: originalString, identifier: Swift.String(monthValue),
                    range: Self.range(from: monthStart, to: offset)
                )
            }
            do throws(Gregorian.Month.Error) {
                month = try Gregorian.Month(rawMonth)
            } catch {
                throw .invalidMonth(
                    input: originalString,
                    value: rawMonth,
                    range: Self.range(from: monthStart, to: offset)
                )
            }
            if Self.consume(0x2E, from: &input) {
                offset += 1
                micro = try Self.parseNumber(&input, offset: &offset, in: originalString)
            }
        }

        var modifier: Swift.String?
        if Self.consume(0x2D, from: &input) {
            offset += 1
            modifier = try Self.parseModifier(&input, offset: &offset, original: originalString)
        }

        switch (month, micro) {
        case (nil, _):
            return .yearOnly(year: year, modifier: modifier)

        case (let month?, nil):
            return .yearMonth(year: year, month: month, modifier: modifier)

        case (let month?, let micro?):
            return .full(year: year, month: month, micro: .init(micro), modifier: modifier)
        }
    }

    static func calendarString(in input: inout Input) -> Swift.String {
        let start = input.checkpoint
        let bytes = Self.scan(&input, while: Self.isCalendarByte)
        input.seek(to: start)
        return Self.string(bytes)
    }

    static func scan(_ input: inout Input, while predicate: (Byte) -> Swift.Bool) -> [Byte] {
        var bytes: [Byte] = []
        while true {
            let mark = input.checkpoint
            guard let byte = input.next(), predicate(byte) else {
                input.seek(to: mark)
                return bytes
            }
            bytes.append(byte)
        }
    }

    static func consume(_ code: Swift.UInt8, from input: inout Input) -> Swift.Bool {
        let mark = input.checkpoint
        if let byte = input.next(), byte.bitPattern == code {
            return true
        }
        input.seek(to: mark)
        return false
    }

    static func string(_ bytes: [Byte]) -> Swift.String {
        Swift.String(decoding: bytes.map(\.bitPattern), as: Swift.UTF8.self)
    }

    static func parseNumber(
        _ input: inout Input,
        offset: inout Swift.UInt,
        in originalString: Swift.String
    ) throws(Version.Calendar.Error) -> Swift.UInt {
        let start = offset
        let mark = input.checkpoint
        let digits = Self.scan(&input) { ASCII.Classification.isDigit($0.bitPattern) }
        let end = start + Swift.UInt(digits.count)
        var slice = digits[...]
        do throws(ASCII.Decimal.Error) {
            let value = try ASCII.Decimal.Parser<ArraySlice<Byte>, Swift.UInt>().parse(&slice)
            offset = end
            return value
        } catch {
            input.seek(to: mark)
            throw .invalidCalendarIdentifier(
                input: originalString,
                identifier: Self.string(digits),
                range: Self.range(from: start, to: end)
            )
        }
    }

    static func parseModifier(
        _ input: inout Input,
        offset: inout Swift.UInt,
        original originalString: Swift.String
    ) throws(Version.Calendar.Error) -> Swift.String {
        let start = offset
        let bytes = Self.scan(&input, while: Self.isModifierByte)
        offset += Swift.UInt(bytes.count)
        if bytes.isEmpty {
            throw .emptyModifier(
                input: originalString,
                range: Self.range(from: start, to: start)
            )
        }
        return Self.string(bytes)
    }

    static func isCalendarByte(_ byte: Byte) -> Swift.Bool {
        ASCII.Classification.isAlphanumeric(byte.bitPattern) || byte.bitPattern == 0x2E
            || byte.bitPattern == 0x2D
    }

    static func isModifierByte(_ byte: Byte) -> Swift.Bool {
        ASCII.Classification.isAlphanumeric(byte.bitPattern) || byte.bitPattern == 0x2D
    }

    static func range(from start: Swift.UInt, to end: Swift.UInt) -> Text.Range {
        Text.Range(start: Version.Calendar.position(start), end: Version.Calendar.position(end))
    }
}
#endif
