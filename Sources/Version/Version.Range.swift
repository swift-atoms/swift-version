extension Version {

    public struct Range<Underlying: Swift::Hashable & Swift::Comparable>: Swift::Hashable {

        public let lowerBound: Bound

        public let upperBound: Bound

        @inlinable
        public init(lowerBound: Bound, upperBound: Bound) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
        }
    }
}

extension Version.Range {
    @inlinable
    public static var all: Self {
        Self(lowerBound: .unbounded, upperBound: .unbounded)
    }

    @inlinable
    public static func exact(_ version: Underlying) -> Self {
        Self(lowerBound: .inclusive(version), upperBound: .inclusive(version))
    }

    @inlinable
    public func contains(_ version: Underlying) -> Swift::Bool {
        switch self.lowerBound {
        case .unbounded: break
        case .inclusive(let lower): if version < lower { return false }
        case .exclusive(let lower): if version <= lower { return false }
        }
        switch self.upperBound {
        case .unbounded: break
        case .inclusive(let upper): if version > upper { return false }
        case .exclusive(let upper): if version >= upper { return false }
        }
        return true
    }
}

extension Version.Range: Swift::Sendable where Underlying: Swift::Sendable {}

extension Version.Range {

    @inlinable
    public var isEmpty: Swift::Bool {
        switch (self.lowerBound, self.upperBound) {
        case (.unbounded, _), (_, .unbounded):
            return false

        case (.inclusive(let lo), .inclusive(let hi)):
            return lo > hi

        case (.inclusive(let lo), .exclusive(let hi)),
            (.exclusive(let lo), .inclusive(let hi)):
            return lo >= hi

        case (.exclusive(let lo), .exclusive(let hi)):
            return lo >= hi
        }
    }

    @inlinable
    public func intersection(_ other: Self) -> Self {
        Self(
            lowerBound: Self.maxLowerBound(self.lowerBound, other.lowerBound),
            upperBound: Self.minUpperBound(self.upperBound, other.upperBound)
        )
    }

    @inlinable
    public func overlaps(_ other: Self) -> Swift::Bool {

        !self.intersection(other).isEmpty
    }

    @inlinable
    public func isSubset(of other: Self) -> Swift::Bool {
        if self.isEmpty { return true }
        return Self.lowerCoversOrEqual(other.lowerBound, vs: self.lowerBound)
            && Self.upperCoversOrEqual(other.upperBound, vs: self.upperBound)
    }

    @inlinable
    public func isSuperset(of other: Self) -> Swift::Bool {
        other.isSubset(of: self)
    }

    @inlinable
    public func contains(_ other: Self) -> Swift::Bool {
        other.isSubset(of: self)
    }

    @usableFromInline
    static func lowerCoversOrEqual(_ enclosing: Bound, vs enclosed: Bound) -> Swift::Bool {
        switch (enclosing, enclosed) {
        case (.unbounded, _): return true
        case (_, .unbounded): return false

        case (.inclusive(let e), .inclusive(let i)): return e <= i
        case (.exclusive(let e), .exclusive(let i)): return e <= i

        case (.inclusive(let e), .exclusive(let i)): return e <= i

        case (.exclusive(let e), .inclusive(let i)): return e < i
        }
    }

    @usableFromInline
    static func upperCoversOrEqual(_ enclosing: Bound, vs enclosed: Bound) -> Swift::Bool {
        switch (enclosing, enclosed) {
        case (.unbounded, _): return true
        case (_, .unbounded): return false

        case (.inclusive(let e), .inclusive(let i)): return e >= i
        case (.exclusive(let e), .exclusive(let i)): return e >= i

        case (.inclusive(let e), .exclusive(let i)): return e >= i
        case (.exclusive(let e), .inclusive(let i)): return e > i
        }
    }

    @usableFromInline
    static func maxLowerBound(_ lhs: Bound, _ rhs: Bound) -> Bound {
        switch (lhs, rhs) {
        case (.unbounded, _): return rhs
        case (_, .unbounded): return lhs

        case (.inclusive(let l), .inclusive(let r)):
            return .inclusive(Swift::max(l, r))

        case (.exclusive(let l), .exclusive(let r)):
            return .exclusive(Swift::max(l, r))

        case (.inclusive(let i), .exclusive(let e)),
            (.exclusive(let e), .inclusive(let i)):
            if e > i { return .exclusive(e) }
            if i > e { return .inclusive(i) }

            return .exclusive(e)
        }
    }

    @usableFromInline
    static func minUpperBound(_ lhs: Bound, _ rhs: Bound) -> Bound {
        switch (lhs, rhs) {
        case (.unbounded, _): return rhs
        case (_, .unbounded): return lhs

        case (.inclusive(let l), .inclusive(let r)):
            return .inclusive(Swift::min(l, r))

        case (.exclusive(let l), .exclusive(let r)):
            return .exclusive(Swift::min(l, r))

        case (.inclusive(let i), .exclusive(let e)),
            (.exclusive(let e), .inclusive(let i)):
            if e < i { return .exclusive(e) }
            if i < e { return .inclusive(i) }

            return .exclusive(e)
        }
    }
}

extension Version.Range: Swift::CustomStringConvertible
where Underlying: Swift::CustomStringConvertible {

    public var description: Swift::String {
        let left: Swift::String
        switch self.lowerBound {
        case .unbounded:
            left = "(-∞"

        case .inclusive(let value):
            left = "[" + value.description

        case .exclusive(let value):
            left = "(" + value.description
        }
        let right: Swift::String
        switch self.upperBound {
        case .unbounded:
            right = "+∞)"

        case .inclusive(let value):
            right = value.description + "]"

        case .exclusive(let value):
            right = value.description + ")"
        }
        return left + ", " + right
    }
}

extension Version.Range {

    @inlinable
    public init(_ range: Swift::Range<Underlying>) {
        self.init(
            lowerBound: .inclusive(range.lowerBound),
            upperBound: .exclusive(range.upperBound)
        )
    }
}
