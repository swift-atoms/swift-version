public import Array
public import Buffer_Linear_Primitive
public import Buffer_Linear
public import Byte_Parser
public import Ownership_Shared_Primitive
internal import Parser

extension Version.Tools: Parseable {

    @_implements(Parseable,Parser)
    public typealias _ParseableParser = Version.Version.Tools.Parser<Byte.Input>

    @inlinable
    public static var parser: _ParseableParser { _ParseableParser() }
}
