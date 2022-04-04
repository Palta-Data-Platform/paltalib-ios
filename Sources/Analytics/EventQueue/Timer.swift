//
//  Timer.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 01.04.2022.
//

import Foundation

struct TimerToken {
    private let cancelHandler: () -> Void

    init(cancelHandler: @escaping () -> Void) {
        self.cancelHandler = cancelHandler
    }

    func cancel() {
        cancelHandler()
    }
}

protocol Timer {
    func scheduleTimer(timeInterval: TimeInterval, on dispatchQueue: DispatchQueue, completion: @escaping () -> Void) -> TimerToken
}
