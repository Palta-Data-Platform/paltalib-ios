//
//  EventQueueAssembly.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07.04.2022.
//

import Foundation
import PaltaLibCore

final class EventQueueAssembly {
    private(set) lazy var eventQueueCore = EventQueueCoreImpl(timer: TimerImpl())

    private(set) lazy var liveEventQueueCore = EventQueueCoreImpl(timer: ImmediateTimer()).do {
        $0.config = .init(
            maxBatchSize: 5,
            uploadInterval: 0,
            uploadThreshold: 3,
            maxEvents: 100,
            maxConcurrentOperations: .max
        )
    }

    private(set) lazy var eventStorage: EventStorage = FileEventStorage()

    private(set) lazy var eventComposer = EventComposerImpl(
        sessionIdProvider: analyticsCoreAssembly.sessionManager,
        userPropertiesProvider: analyticsCoreAssembly.userPropertiesKeeper,
        deviceInfoProvider: DeviceInfoProviderImpl(),
        trackingOptionsProvider: analyticsCoreAssembly.trackingOptionsProvider
    )

    private(set) lazy var eventSender = EventSenderImpl(httpClient: coreAssembly.httpClient)

    private(set) lazy var eventQueue = EventQueueImpl(
        core: eventQueueCore,
        liveCore: liveEventQueueCore,
        storage: eventStorage,
        sender: eventSender,
        eventComposer: eventComposer,
        sessionManager: analyticsCoreAssembly.sessionManager,
        timer: TimerImpl()
    )

    private(set) lazy var identityLogger = IdentityLogger(eventQueue: eventQueue)

    private(set) lazy var revenueLogger = RevenueLogger(eventQueue: eventQueue)

    private let coreAssembly: CoreAssembly
    private let analyticsCoreAssembly: AnalyticsCoreAssembly

    init(coreAssembly: CoreAssembly, analyticsCoreAssembly: AnalyticsCoreAssembly) {
        self.coreAssembly = coreAssembly
        self.analyticsCoreAssembly = analyticsCoreAssembly
    }
}
