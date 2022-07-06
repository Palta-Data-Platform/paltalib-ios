//  

import Foundation

public struct FirstEnum {
    public static let one: FirstEnum = FirstEnum(rawValue: 0)

    public static let two: FirstEnum = FirstEnum(rawValue: 1)

    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
}

public struct SecondEnum {
    public static let one1: SecondEnum = SecondEnum(rawValue: 0)

    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
}
