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
    @discardableResult
    func scheduleTimer(timeInterval: TimeInterval, on dispatchQueue: DispatchQueue, completion: @escaping () -> Void) -> TimerToken
}

final class TimerImpl: Timer {
    @discardableResult
    func scheduleTimer(
        timeInterval: TimeInterval,
        on dispatchQueue: DispatchQueue,
        completion: @escaping () -> Void
    ) -> TimerToken {
        let workItem = DispatchWorkItem(block: completion)
        dispatchQueue.asyncAfter(deadline: .now() + timeInterval, execute: workItem)

        return TimerToken(cancelHandler: { workItem.cancel() })
    }
}

final class ImmediateTimer: Timer {
    func scheduleTimer(
        timeInterval: TimeInterval,
        on dispatchQueue: DispatchQueue,
        completion: @escaping () -> Void
    ) -> TimerToken {
        dispatchQueue.async(execute: completion)
        return TimerToken {}
    }
}
