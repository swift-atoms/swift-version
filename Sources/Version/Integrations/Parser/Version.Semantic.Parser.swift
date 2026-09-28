#if Parser
public import Byte
internal import Ordinal
public import Parser
internal import Text

extension Version.Semantic {

    public struct Parser: Swift.Sendable {

        @inlinable
        public init() {}
    }
}

extension Version.Semantic.Parser: Parsing {

    public typealias Output = Version.Semantic
    public typealias Failure = Version.Semantic.ParserError

    public func parse(_ input: inout ArraySlice<Byte>) throws(Failure) -> Output {
        let originalLength = Self.findSemVerEnd(in: input)
        let originalString = Self.string(from: input, count: originalLength)
        var offset = 0

        let major = try Self.parseCoreNumber(&input, offset: &offset, in: originalString)
        try Self.consumeDelimiter(0x2E, in: &input, offset: &offset, original: originalString)
        let minor = try Self.parseCoreNumber(&input, offset: &offset, in: originalString)
        try Self.consumeDelimiter(0x2E, in: &input, offset: &offset, original: originalString)
        let patch = try Self.parseCoreNumber(&input, offset: &offset, in: originalString)

        var preRelease: [Version.Semantic.Identifier] = []
        if !input.isEmpty, input[input.startIndex + 0].bitPattern == 0x2D {
            input.removeFirst(1)
            offset += 1
            preRelease = try Self.parsePreReleaseIdentifiers(
                &input,
                offset: &offset,
                original: originalString
            )
        }

        var build: [Swift.String] = []
        if !input.isEmpty, input[input.startIndex + 0].bitPattern == 0x2B {
            input.removeFirst(1)
            offset += 1
            build = try Self.parseBuildMetadataIdentifiers(
                &input,
                offset: &offset,
                original: originalString
            )
        }

        return Version.Semantic(
            major: .init(major),
            minor: .init(minor),
            patch: .init(patch),
            preReleaseIdentifiers: preRelease,
            buildMetadataIdentifiers: build
        )
    }

    static func findSemVerEnd(in input: ArraySlice<Byte>) -> Swift.Int {
        var offset = 0
        while offset < input.count, Self.isSemVerByte(input[input.startIndex + offset]) {
            offset += 1
        }
        return offset
    }

    static func parseCoreNumber(
        _ input: inout ArraySlice<Byte>,
        offset: inout Swift.Int,
        in originalString: Swift.String
    ) throws(Failure) -> Swift.UInt {
        let startOffset = offset
        guard !input.isEmpty, Self.isDigit(input[input.startIndex + 0]) else {
            throw .invalidVersionCoreIdentifier(
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
            throw .invalidVersionCoreIdentifier(
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
                throw .invalidVersionCoreIdentifier(
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

    static func consumeDelimiter(
        _ byte: Swift.UInt8,
        in input: inout ArraySlice<Byte>,
        offset: inout Swift.Int,
        original originalString: Swift.String
    ) throws(Failure) {
        guard !input.isEmpty, input[input.startIndex + 0].bitPattern == byte else {
            throw .invalidVersionCoreIdentifierCount(
                input: originalString,
                found: Self.countCoreParts(in: originalString),
                range: Self.range(from: offset, to: offset)
            )
        }
        input.removeFirst(1)
        offset += 1
    }

    static func countCoreParts(in original: Swift.String) -> Swift.Int {
        var count = 1
        for byte in original.utf8 {
            if byte == 0x2D || byte == 0x2B { break }
            if byte == 0x2E { count += 1 }
        }
        return count
    }

    static func parsePreReleaseIdentifiers(
        _ input: inout ArraySlice<Byte>,
        offset: inout Swift.Int,
        original originalString: Swift.String
    ) throws(Failure) -> [Version.Semantic.Identifier] {
        var identifiers: [Version.Semantic.Identifier] = []
        repeat {
            let startOffset = offset
            let (text, count) = Self.takeIdentifier(from: input)
            if count == 0 {
                throw .emptyPreReleaseIdentifier(
                    input: originalString,
                    range: Self.range(from: startOffset, to: startOffset)
                )
            }
            let valid = (0..<count).allSatisfy {
                Self.isIdentifierByte(input[input.startIndex + $0])
            }
            let range = Self.range(from: startOffset, to: startOffset + count)
            guard valid else {
                throw .invalidPreReleaseIdentifierCharacters(
                    input: originalString,
                    identifier: text,
                    range: range
                )
            }
            let allDigits = (0..<count).allSatisfy { Self.isDigit(input[input.startIndex + $0]) }
            if allDigits {
                if input[input.startIndex + 0].bitPattern == 0x30, count > 1 {
                    throw .leadingZeroInNumericPreReleaseIdentifier(
                        input: originalString,
                        identifier: text,
                        range: range
                    )
                }
                guard let value = Swift.UInt(text) else {
                    throw .invalidPreReleaseIdentifierCharacters(
                        input: originalString,
                        identifier: text,
                        range: range
                    )
                }
                identifiers.append(.numeric(value))
            } else {
                identifiers.append(.alphanumeric(text))
            }
            input.removeFirst(count)
            offset += count
        } while Self.consumeIfDot(&input, offset: &offset)
        return identifiers
    }

    static func parseBuildMetadataIdentifiers(
        _ input: inout ArraySlice<Byte>,
        offset: inout Swift.Int,
        original originalString: Swift.String
    ) throws(Failure) -> [Swift.String] {
        var identifiers: [Swift.String] = []
        repeat {
            let startOffset = offset
            let (text, count) = Self.takeIdentifier(from: input)
            if count == 0 {
                throw .emptyBuildMetadataIdentifier(
                    input: originalString,
                    range: Self.range(from: startOffset, to: startOffset)
                )
            }
            let valid = (0..<count).allSatisfy {
                Self.isIdentifierByte(input[input.startIndex + $0])
            }
            guard valid else {
                throw .invalidBuildMetadataIdentifierCharacters(
                    input: originalString,
                    identifier: text,
                    range: Self.range(from: startOffset, to: startOffset + count)
                )
            }
            identifiers.append(text)
            input.removeFirst(count)
            offset += count
        } while Self.consumeIfDot(&input, offset: &offset)
        return identifiers
    }

    static func takeIdentifier(from input: ArraySlice<Byte>) -> (Swift.String, Swift.Int) {
        var count = 0
        while count < input.count {
            let byte = input[input.startIndex + count].bitPattern
            if byte == 0x2E || byte == 0x2B { break }
            count += 1
        }
        return (Self.string(from: input, count: count), count)
    }

    static func consumeIfDot(_ input: inout ArraySlice<Byte>, offset: inout Swift.Int) -> Swift.Bool {
        guard !input.isEmpty, input[input.startIndex + 0].bitPattern == 0x2E else { return false }
        input.removeFirst(1)
        offset += 1
        return true
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

    static func isSemVerByte(_ byte: Byte) -> Swift.Bool {
        Self.isIdentifierByte(byte) || byte.bitPattern == 0x2E || byte.bitPattern == 0x2B
    }

    static func isIdentifierByte(_ byte: Byte) -> Swift.Bool {
        let value = byte.bitPattern
        return Self.isDigit(byte)
            || (0x41...0x5A).contains(value)
            || (0x61...0x7A).contains(value)
            || value == 0x2D
    }

    static func isDigit(_ byte: Byte) -> Swift.Bool {
        (0x30...0x39).contains(byte.bitPattern)
    }
}
#endif
