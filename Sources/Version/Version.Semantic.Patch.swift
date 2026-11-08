public import Tagged

extension Version.Semantic {

    public enum Patch: Swift::Sendable {}
}

extension Version.Semantic.Patch {

    public typealias Value = Tagged<Version.Semantic.Patch, Swift::UInt>
}
