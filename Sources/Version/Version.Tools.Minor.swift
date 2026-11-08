public import Tagged

extension Version.Tools {

    public enum Minor: Swift::Sendable {}
}

extension Version.Tools.Minor {

    public typealias Value = Tagged<Version.Tools.Minor, Swift::UInt>
}
