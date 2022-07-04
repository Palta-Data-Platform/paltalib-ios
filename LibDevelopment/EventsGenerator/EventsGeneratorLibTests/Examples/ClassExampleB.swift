//  This is my header
//  A new line

import Foundation

open class BClass: NSNumber {
    fileprivate var int: Int?

    internal convenience init(int: Int?) {
        self.int = int
    }
}
