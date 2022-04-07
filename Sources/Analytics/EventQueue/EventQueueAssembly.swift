//
//  EventQueueAssembly.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07.04.2022.
//

import Foundation
import PaltaLibCore

final class EventQueueAssembly {
    private(set) lazy var eventQueueCore: EventQueueCore = EventQueueCoreImpl(timer: TimerImpl())

    private(set) lazy var eventStorage: EventStorage = FileEventStorage()

    private(set) lazy var eventComposer: EventComposer = EventComposerImpl(sessionIdProvider: sessionManager)

    private(set) lazy var sessionManager = SessionManagerImpl(
        userDefaults: .standard,
        notificationCenter: .default
    )

    private(set) lazy var eventQueue = EventQueue(
        core: eventQueueCore,
        storage: eventStorage,
        sender: { fatalError() }(),
        eventComposer: eventComposer,
        sessionManager: sessionManager,
        timer: TimerImpl()
    )

    private let coreAssembly: CoreAssembly

    init(coreAssembly: CoreAssembly) {
        self.coreAssembly = coreAssembly
    }
}
