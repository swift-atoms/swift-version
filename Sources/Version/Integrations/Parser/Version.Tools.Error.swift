#if Parser

public import Text

extension Version.Tools {

    public enum ParserError: Swift.Error, Swift.Sendable, Swift.Hashable {

        case invalidToolsVersionIdentifierCount(input: Swift.String, range: Text.Range)

        case invalidToolsVersionIdentifier(
            input: Swift.String,
            identifier: Swift.String,
            range: Text.Range
        )
    }
}

extension Version.Tools.ParserError {

    @inlinable
    public var range: Text.Range {
        switch self {
        case .invalidToolsVersionIdentifierCount(_, let range): return range
        case .invalidToolsVersionIdentifier(_, _, let range): return range
        }
    }

    @inlinable
    public var input: Swift.String {
        switch self {
        case .invalidToolsVersionIdentifierCount(let input, _): return input
        case .invalidToolsVersionIdentifier(let input, _, _): return input
        }
    }
}
#endif
