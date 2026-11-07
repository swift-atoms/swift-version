public import Tagged

extension Version.Tools {

    public enum Patch: Swift::Sendable {}
}

extension Version.Tools.Patch {

    public typealias Value = Tagged<Version.Tools.Patch, Swift::UInt>
}
