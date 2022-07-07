//
//  Timestamp.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation

#if DEBUG
var mockedTimestamp: Int?
#endif

func currentTimestamp() -> Int {
    #if DEBUG
    return mockedTimestamp ?? realCurrentTimestamp()
    #else
    return realCurrentTimestamp()
    #endif
}

private func realCurrentTimestamp() -> Int {
    Int((Date().timeIntervalSince1970 * 1000).rounded())
}
