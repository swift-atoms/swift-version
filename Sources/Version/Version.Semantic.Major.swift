public import Tagged

extension Version.Semantic {

    public enum Major: Swift::Sendable {}
}

extension Version.Semantic.Major {

    public typealias Value = Tagged<Version.Semantic.Major, Swift::UInt>
}
