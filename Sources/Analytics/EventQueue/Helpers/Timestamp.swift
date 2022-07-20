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

private var appStartTimestamp: Int!
private var appStartClock: Int!

private func realCurrentTimestamp() -> Int {
    appStartTimestamp + getClock() - appStartClock
}

private func getClock() -> Int {
    let nanosecs = clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)
    return Int(nanosecs / 1_000_000)
}

@objc(PBTimeKeeper)
private class TimeKeeper: NSObject {
    @objc
    class func recordTime() {
        appStartTimestamp = Int((Date().timeIntervalSince1970 * 1000).rounded())
        appStartClock = getClock()
    }
}
