//
//  Timestamp.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import Foundation

extension Int {
    #if DEBUG
    static var timestampMock: Int?
    #endif
    
    static func currentTimestamp() -> Int {
        #if DEBUG
        if let timestampMock = timestampMock {
            return timestampMock
        }
        #endif
        
        return Int(Date().timeIntervalSince1970 * 1000)
    }
}
