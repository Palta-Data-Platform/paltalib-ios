//  This is my header
//  A new line

import Foundation
import UIKit

private struct AStruct {
    public let string: String

    fileprivate init(string: String?) throws {
        self.string = string ?? ""
    }

    internal func doNothing() {
    }
}
