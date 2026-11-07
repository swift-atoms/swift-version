extension Version.Range {

    public enum Bound: Swift::Hashable {

        case unbounded

        case inclusive(Underlying)

        case exclusive(Underlying)
    }
}

extension Version.Range.Bound: Swift::Sendable where Underlying: Swift::Sendable {}

extension Version.Range.Bound: Swift::CustomStringConvertible
where Underlying: Swift::CustomStringConvertible {

    public var description: Swift::String {
        switch self {
        case .unbounded:
            return "unbounded"

        case .inclusive(let value):
            return "inclusive(" + value.description + ")"

        case .exclusive(let value):
            return "exclusive(" + value.description + ")"
        }
    }
}
