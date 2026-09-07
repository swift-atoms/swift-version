extension Version.Set: Swift.CustomStringConvertible
where Underlying: Swift.CustomStringConvertible {

    public var description: Swift.String {
        switch self {
        case .empty:
            return "∅"

        case .any:
            return "*"

        case .exact(let value):
            return "{" + value.description + "}"

        case .range(let interval):
            return interval.description

        case .union(let members):
            switch members.count {
            case 0:
                return "∅"

            case 1:
                return members[0].description

            default:
                return "(" + members.map(\.description).joined(separator: " ∪ ") + ")"
            }
        }
    }
}
