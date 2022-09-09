//  

import Foundation

public struct Result {
    public static let success: Result = Result(rawValue: 1)

    public static let skip: Result = Result(rawValue: 2)

    public static let error: Result = Result(rawValue: 3)

    public let rawValue: Int64

    public init(rawValue: Int64) {
        self.rawValue = rawValue
    }
}
