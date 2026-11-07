public import Tagged

extension Version.Semantic {

    public enum Minor: Swift::Sendable {}
}

extension Version.Semantic.Minor {

    public typealias Value = Tagged<Version.Semantic.Minor, Swift::UInt>
}
