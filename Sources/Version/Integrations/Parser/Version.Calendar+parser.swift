#if Parser && Calendar

public import Byte
public import Cursor
public import Parser

extension Version.Calendar {


    @inlinable
    public static var parser: Version.Calendar.Parser<ArraySlice<Byte>> { Version.Calendar.Parser<ArraySlice<Byte>>() }
}
#endif
