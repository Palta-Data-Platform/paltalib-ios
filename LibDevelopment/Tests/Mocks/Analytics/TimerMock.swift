//
//  TimerMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 01.04.2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class TimerMock: PaltaLibAnalytics.Timer {
    var passedInterval: TimeInterval?

    private var dispatchQueue: DispatchQueue?
    private var completion: (() -> Void)?

    func scheduleTimer(
        timeInterval: TimeInterval,
        on dispatchQueue: DispatchQueue,
        completion: @escaping () -> Void
    ) -> TimerToken {
        self.passedInterval = timeInterval
        self.dispatchQueue = dispatchQueue
        self.completion = completion

        return TimerToken { [weak self] in self?.completion = nil }
    }

    func fire() {
        dispatchQueue?.async {
            self.completion?()
        }
    }
}
