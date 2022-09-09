//  This is my header
//  A new line

import Foundation

fileprivate class BClass: Equatable, Hashable {
    fileprivate let int: Int?

    internal required init(int: Int?) {
        self.int = int
    }
}
