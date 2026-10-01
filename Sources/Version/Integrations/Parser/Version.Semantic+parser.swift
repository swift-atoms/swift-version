#if Parser

import Byte
import Parser

extension Version.Semantic {


    @inlinable
    public static var parser: Version.Semantic.Parser { Version.Semantic.Parser() }
}
#endif
