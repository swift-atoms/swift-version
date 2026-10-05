#if Parser
public import Byte
internal import Ordinal
public import Parser
internal import Text

extension Version.Tools {

    public struct Parser: Swift.Sendable {

        @inlinable
        public init() {}
    }
}

extension Version.Tools.Parser: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }


    public typealias Output = Version.Tools
    public typealias Failure = Version.Tools.ParserError

    public func parse(_ input: inout ArraySlice<Byte>) throws(Failure) -> Output {
        let originalLength = Self.findToolsVersionEnd(in: input)
        let originalString = Self.string(from: input, count: originalLength)
        var offset = 0

        let major = try Self.parseNumber(&input, offset: &offset, in: originalString)
        try Self.consumeDot(in: &input, offset: &offset, original: originalString)
        let minor = try Self.parseNumber(&input, offset: &offset, in: originalString)

        var patch: Swift.UInt?
        if !input.isEmpty, input[input.startIndex + 0].bitPattern == 0x2E {
            input.removeFirst(1)
            offset += 1
            patch = try Self.parseNumber(&input, offset: &offset, in: originalString)
        }

        return Version.Tools(
            major: .init(major),
            minor: .init(minor),
            patch: patch.map { .init($0) }
        )
    }

    static func findToolsVersionEnd(in input: ArraySlice<Byte>) -> Swift.Int {
        var offset = 0
        while offset < input.count, Self.isToolsVersionByte(input[input.startIndex + offset]) {
            offset += 1
        }
        return offset
    }

    static func parseNumber(
        _ input: inout ArraySlice<Byte>,
        offset: inout Swift.Int,
        in originalString: Swift.String
    ) throws(Failure) -> Swift.UInt {
        let startOffset = offset
        guard !input.isEmpty, Self.isDigit(input[input.startIndex + 0]) else {
            throw .invalidToolsVersionIdentifier(
                input: originalString,
                identifier: "",
                range: Self.range(from: startOffset, to: startOffset)
            )
        }
        let firstByte = input[input.startIndex + 0]

        var count = 0
        while count < input.count, Self.isDigit(input[input.startIndex + count]) {
            count += 1
        }
        let identifier = Self.string(from: input, count: count)
        if firstByte.bitPattern == 0x30, count > 1 {
            throw .invalidToolsVersionIdentifier(
                input: originalString,
                identifier: identifier,
                range: Self.range(from: startOffset, to: startOffset + count)
            )
        }

        var value: Swift.UInt = 0
        for index in 0..<count {
            let digit = Swift.UInt(input[input.startIndex + index].bitPattern - 0x30)
            let (scaled, multipliedOverflow) = value.multipliedReportingOverflow(by: 10)
            let (next, addedOverflow) = scaled.addingReportingOverflow(digit)
            guard !multipliedOverflow, !addedOverflow else {
                throw .invalidToolsVersionIdentifier(
                    input: originalString,
                    identifier: identifier,
                    range: Self.range(from: startOffset, to: startOffset + count)
                )
            }
            value = next
        }
        input.removeFirst(count)
        offset += count
        return value
    }

    static func consumeDot(
        in input: inout ArraySlice<Byte>,
        offset: inout Swift.Int,
        original originalString: Swift.String
    ) throws(Failure) {
        guard !input.isEmpty, input[input.startIndex + 0].bitPattern == 0x2E else {
            throw .invalidToolsVersionIdentifierCount(
                input: originalString,
                range: Self.range(from: offset, to: offset)
            )
        }
        input.removeFirst(1)
        offset += 1
    }

    static func string(from input: ArraySlice<Byte>, count: Swift.Int) -> Swift.String {
        let bytes = (0..<count).map { input[input.startIndex + $0].bitPattern }
        return Swift.String(decoding: bytes, as: Swift.UTF8.self)
    }

    static func range(from start: Swift.Int, to end: Swift.Int) -> Text.Range {
        Text.Range(
            start: Text.Position(_unchecked: Ordinal(Swift.UInt(start))),
            end: Text.Position(_unchecked: Ordinal(Swift.UInt(end)))
        )
    }

    static func isToolsVersionByte(_ byte: Byte) -> Swift.Bool {
        Self.isDigit(byte) || byte.bitPattern == 0x2E
    }

    static func isDigit(_ byte: Byte) -> Swift.Bool {
        (0x30...0x39).contains(byte.bitPattern)
    }
}
#endif
