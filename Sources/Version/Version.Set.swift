extension Version {

    public indirect enum Set<Underlying: Swift::Hashable & Swift::Comparable>: Swift::Hashable {

        case empty

        case any

        case exact(Underlying)

        case range(Version.Range<Underlying>)

        case union([Version.Set<Underlying>])
    }
}

extension Version.Set {

    @inlinable
    public func contains(_ version: Underlying) -> Swift::Bool {
        switch self {
        case .empty:
            return false

        case .any:
            return true

        case .exact(let target):
            return version == target

        case .range(let interval):
            return interval.contains(version)

        case .union(let members):
            for member in members where member.contains(version) {
                return true
            }
            return false
        }
    }
}

extension Version.Set: Swift::Sendable where Underlying: Swift::Sendable {}

extension Version.Set {

    @inlinable
    public var isEmpty: Swift::Bool {
        switch self {
        case .empty:
            return true

        case .any, .exact:
            return false

        case .range(let interval):
            return interval.isEmpty

        case .union(let members):
            for member in members where !member.isEmpty {
                return false
            }
            return true
        }
    }

    @inlinable
    public func normalized() -> Self {
        switch self {
        case .empty, .any, .exact:
            return self

        case .range(let interval):
            return interval.isEmpty ? .empty : self

        case .union(let members):
            var flattened: [Self] = []
            for member in members {
                let canonical = member.normalized()
                switch canonical {
                case .empty:
                    continue

                case .any:
                    return .any

                case .union(let nested):
                    flattened.append(contentsOf: nested)

                default:
                    flattened.append(canonical)
                }
            }
            switch flattened.count {
            case 0: return .empty
            case 1: return flattened[0]
            default: return .union(flattened)
            }
        }
    }

    @inlinable
    public func union(_ other: Self) -> Self {
        Self.union([self, other]).normalized()
    }

    @inlinable
    public func intersection(_ other: Self) -> Self {
        switch (self, other) {
        case (.empty, _), (_, .empty):
            return .empty

        case (.any, let value), (let value, .any):
            return value.normalized()

        case (.exact(let lhs), .exact(let rhs)):
            return lhs == rhs ? .exact(lhs) : .empty

        case (.exact(let value), _):
            return other.contains(value) ? .exact(value) : .empty

        case (_, .exact(let value)):
            return self.contains(value) ? .exact(value) : .empty

        case (.range(let lhs), .range(let rhs)):
            let intersected = lhs.intersection(rhs)
            return intersected.isEmpty ? .empty : .range(intersected)

        case (.union(let members), _):
            return Self.union(members.map { $0.intersection(other) }).normalized()

        case (_, .union(let members)):
            return Self.union(members.map { self.intersection($0) }).normalized()
        }
    }
}

extension Version.Set: Swift::CustomDebugStringConvertible
where Underlying: Swift::CustomStringConvertible {

    public var debugDescription: Swift::String {
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

extension Version.Set: Swift::CustomStringConvertible
where Underlying: Swift::CustomStringConvertible {

    public var description: Swift::String {
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
