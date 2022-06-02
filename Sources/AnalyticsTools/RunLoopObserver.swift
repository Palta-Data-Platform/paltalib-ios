//
//  RunLoopObserver.swift
//  AnalyticsTools
//
//  Created by Vyacheslav Beltyukov on 01/06/2022.
//

import Foundation

final class RunLoopObserver: NSObject {
    private let runLoop: RunLoop
    private let handler: () -> Void

    private var observer: CFRunLoopObserver?

    init(runLoop: RunLoop, _ handler: @escaping () -> Void) {
        self.runLoop = runLoop
        self.handler = handler
    }

    func start() {
        observer = CFRunLoopObserverCreateWithHandler(
            kCFAllocatorDefault,
            CFRunLoopActivity.afterWaiting.rawValue,
            true,
            0, { [handler] _, _ in
                handler()
            })

        CFRunLoopAddObserver(runLoop.getCFRunLoop(), observer, .commonModes)
    }

    func stop() {
        CFRunLoopRemoveObserver(runLoop.getCFRunLoop(), observer, .defaultMode)
    }
}

