import Tagged
public import Version

extension Version.Semantic {

    public enum Error: Swift.Error, Swift.Sendable, Swift.Equatable {

        case invalidCore

        case invalidNumericComponent(Swift.String)

        case leadingZero(Swift.String)

        case invalidPreReleaseIdentifier(Swift.String)

        case invalidBuildMetadataIdentifier(Swift.String)
    }

    public init(parsing description: Swift.String) throws(Error) {
        let buildSplit = description.split(
            separator: "+",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )
        guard buildSplit.count <= 2 else { throw .invalidCore }

        let release = buildSplit[0]
        let buildMetadataIdentifiers: [Swift.String]
        if buildSplit.count == 2 {
            buildMetadataIdentifiers = try Self.parseBuildMetadata(buildSplit[1])
        } else {
            buildMetadataIdentifiers = []
        }

        let preReleaseSplit = release.split(
            separator: "-",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )
        guard preReleaseSplit.count <= 2 else { throw .invalidCore }

        let core = preReleaseSplit[0].split(separator: ".", omittingEmptySubsequences: false)
        guard core.count == 3 else { throw .invalidCore }

        let major = try Self.parseCoreNumber(core[0])
        let minor = try Self.parseCoreNumber(core[1])
        let patch = try Self.parseCoreNumber(core[2])

        let preReleaseIdentifiers: [Identifier]
        if preReleaseSplit.count == 2 {
            preReleaseIdentifiers = try Self.parsePreRelease(preReleaseSplit[1])
        } else {
            preReleaseIdentifiers = []
        }

        self.init(
            major: major,
            minor: minor,
            patch: patch,
            preReleaseIdentifiers: preReleaseIdentifiers,
            buildMetadataIdentifiers: buildMetadataIdentifiers
        )
    }

    private static func parseCoreNumber(_ component: Swift.Substring) throws(Error) -> Swift.UInt {
        let string = Swift.String(component)
        guard Self.isASCIIDigits(component), let value = Swift.UInt(string) else {
            throw .invalidNumericComponent(string)
        }
        guard component.count == 1 || component.first != "0" else {
            throw .leadingZero(string)
        }
        return value
    }

    private static func parsePreRelease(
        _ value: Swift.Substring
    ) throws(Error) -> [Identifier] {
        let components = value.split(separator: ".", omittingEmptySubsequences: false)
        return try components.map { component throws(Error) in
            let string = Swift.String(component)
            guard !component.isEmpty, Self.isASCIIIdentifier(component) else {
                throw .invalidPreReleaseIdentifier(string)
            }
            if Self.isASCIIDigits(component) {
                guard component.count == 1 || component.first != "0" else {
                    throw .leadingZero(string)
                }
                guard let numeric = Swift.UInt(string) else {
                    throw .invalidNumericComponent(string)
                }
                return .numeric(numeric)
            }
            return .alphanumeric(string)
        }
    }

    private static func parseBuildMetadata(
        _ value: Swift.Substring
    ) throws(Error) -> [Swift.String] {
        let components = value.split(separator: ".", omittingEmptySubsequences: false)
        return try components.map { component throws(Error) in
            let string = Swift.String(component)
            guard !component.isEmpty, Self.isASCIIIdentifier(component) else {
                throw .invalidBuildMetadataIdentifier(string)
            }
            return string
        }
    }

    private static func isASCIIDigits(_ value: Swift.Substring) -> Swift.Bool {
        !value.isEmpty && value.unicodeScalars.allSatisfy { (48...57).contains($0.value) }
    }

    private static func isASCIIIdentifier(_ value: Swift.Substring) -> Swift.Bool {
        value.unicodeScalars.allSatisfy {
            (48...57).contains($0.value)
                || (65...90).contains($0.value)
                || (97...122).contains($0.value)
                || $0.value == 45
        }
    }
}

extension Version.Semantic: Swift.CustomStringConvertible {

    public var description: Swift.String {
        var result = "\(major.underlying).\(minor.underlying).\(patch.underlying)"

        if !preReleaseIdentifiers.isEmpty {
            result += "-" + preReleaseIdentifiers.map {
                switch $0 {
                case .numeric(let value): return Swift.String(value)
                case .alphanumeric(let value): return value
                }
            }.joined(separator: ".")
        }

        if !buildMetadataIdentifiers.isEmpty {
            result += "+" + buildMetadataIdentifiers.joined(separator: ".")
        }

        return result
    }
}
