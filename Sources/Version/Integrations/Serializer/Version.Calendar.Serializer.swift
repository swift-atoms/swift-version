#if Serializer && Calendar
public import Byte
public import Serializer

extension Version.Calendar {
    public struct Serializer<Buffer: Swift.RangeReplaceableCollection>: Swift.Sendable
    where Buffer: Swift.Sendable, Buffer.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension Version.Calendar.Serializer: Serializing {
    public typealias Output = Version.Calendar
    public typealias Failure = Swift.Never

    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) {
        buffer.append(contentsOf: output.description.utf8.lazy.map(Byte.init(bitPattern:)))
    }
}
#endif
