extension Version.Set: Swift.CustomDebugStringConvertible
where Underlying: Swift.CustomStringConvertible {

    public var debugDescription: Swift.String {
        switch self {
        case .empty:
            return ".empty"

        case .any:
            return ".any"

        case .exact(let value):
            return ".exact(" + value.description + ")"

        case .range(let interval):
            return ".range(" + interval.description + ")"

        case .union(let members):
            let inner = members.map(\.debugDescription).joined(separator: ", ")
            return ".union([" + inner + "])"
        }
    }
}
