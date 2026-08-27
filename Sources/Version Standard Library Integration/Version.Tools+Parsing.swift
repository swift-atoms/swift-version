import Tagged
public import Version

extension Version.Tools {

    public enum Error: Swift.Error, Swift.Sendable, Swift.Equatable {

        case invalidComponentCount

        case invalidNumericComponent(Swift.String)

        case leadingZero(Swift.String)
    }

    public init(parsing description: Swift.String) throws(Error) {
        let components = description.split(separator: ".", omittingEmptySubsequences: false)
        guard components.count == 2 || components.count == 3 else {
            throw .invalidComponentCount
        }

        let major = try Self.parseNumber(components[0])
        let minor = try Self.parseNumber(components[1])
        let patch = try components.count == 3 ? Self.parseNumber(components[2]) : nil

        self.init(major: major, minor: minor, patch: patch)
    }

    private static func parseNumber(_ component: Swift.Substring) throws(Error) -> Swift.UInt {
        let string = Swift.String(component)
        guard
            !component.isEmpty,
            component.unicodeScalars.allSatisfy({ (48...57).contains($0.value) }),
            let value = Swift.UInt(string)
        else {
            throw .invalidNumericComponent(string)
        }
        guard component.count == 1 || component.first != "0" else {
            throw .leadingZero(string)
        }
        return value
    }
}

extension Version.Tools: Swift.CustomStringConvertible {

    public var description: Swift.String {
        var result = "\(major.underlying).\(minor.underlying)"
        if let patch {
            result += ".\(patch.underlying)"
        }
        return result
    }
}
