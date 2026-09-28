#if Serializer
public import Byte
public import Serializer

extension Version.Semantic {
    public struct Serializer<Buffer: Swift.RangeReplaceableCollection>: Swift.Sendable
    where Buffer: Swift.Sendable, Buffer.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension Version.Semantic.Serializer: Serializing {
    public typealias Output = Version.Semantic
    public typealias Failure = Swift.Never

    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) {
        buffer.append(contentsOf: output.description.utf8.lazy.map(Byte.init(bitPattern:)))
    }
}
#endif
