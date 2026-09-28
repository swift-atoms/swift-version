#if Calendar
public import Tagged
public import Calendar_Gregorian

extension Version {

    public enum Calendar: Swift.Sendable, Swift.Hashable, Swift.Comparable, Swift
            .CustomStringConvertible
    {

        case yearOnly(year: Gregorian.Year, modifier: Swift.String? = nil)

        case yearMonth(year: Gregorian.Year, month: Gregorian.Month, modifier: Swift.String? = nil)

        case full(
            year: Gregorian.Year,
            month: Gregorian.Month,
            micro: Micro.Value,
            modifier: Swift.String? = nil
        )

    }
}

extension Version.Calendar {

    public var description: Swift.String {
        func padded(_ value: Swift.UInt) -> Swift.String {
            value < 10 ? "0\(value)" : Swift.String(value)
        }
        func suffixed(_ value: Swift.String, _ modifier: Swift.String?) -> Swift.String {
            modifier.map { value + "-" + $0 } ?? value
        }
        switch self {
        case .yearOnly(let year, let modifier):
            return suffixed(Swift.String(year.rawValue), modifier)
        case .yearMonth(let year, let month, let modifier):
            return suffixed("\(year.rawValue).\(padded(Swift.UInt(month.rawValue)))", modifier)
        case .full(let year, let month, let micro, let modifier):
            return suffixed(
                "\(year.rawValue).\(padded(Swift.UInt(month.rawValue))).\(padded(micro.underlying))",
                modifier
            )
        }
    }

    public static func < (lhs: Self, rhs: Self) -> Swift.Bool {
        let (ly, lm, lu, lp, lmod) = lhs.normalized()
        let (ry, rm, ru, rp, rmod) = rhs.normalized()
        if ly != ry { return ly < ry }
        if lm != rm { return lm < rm }
        if lu != ru { return lu < ru }
        if lp != rp { return lp < rp }
        switch (lmod, rmod) {
        case (nil, nil): return false
        case (nil, _?): return false
        case (_?, nil): return true
        case (let l?, let r?): return l < r
        }
    }

    @usableFromInline
    func normalized() -> (
        year: Swift.Int, month: Swift.Int, micro: Swift.UInt, precision: Swift.Int, modifier: Swift.String?
    ) {
        switch self {
        case .yearOnly(let y, let mod):
            return (y.rawValue, 0, 0, 0, mod)

        case .yearMonth(let y, let m, let mod):
            return (y.rawValue, m.rawValue, 0, 1, mod)

        case .full(let y, let m, let micro, let mod):
            return (y.rawValue, m.rawValue, micro.underlying, 2, mod)
        }
    }

}
#endif
