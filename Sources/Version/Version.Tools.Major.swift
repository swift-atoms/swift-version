public import Tagged

extension Version.Tools {

    public enum Major: Swift::Sendable {}
}

extension Version.Tools.Major {

    public typealias Value = Tagged<Version.Tools.Major, Swift::UInt>
}
