//
//  Timestamp.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import Foundation

extension Int {
    static func currentTimestamp() -> Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }
}
