#if Calendar
    extension Version.Calendar {

        public enum Micro: Swift::Sendable {}
    }
#endif

#if Calendar
    public import Tagged

    extension Version.Calendar.Micro {

        public typealias Value = Tagged<Version.Calendar.Micro, Swift::UInt>
    }
#endif
