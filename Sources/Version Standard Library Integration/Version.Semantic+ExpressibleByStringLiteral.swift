public import Version

extension Version.Semantic: ExpressibleByStringLiteral {

    @inlinable
    public init(stringLiteral value: Swift.String) {
        do {
            self = try Version.Semantic(parsing: value)
        } catch {
            fatalError("Version.Semantic literal failed to parse: \(value): \(error)")
        }
    }
}
