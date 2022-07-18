//
//  EventQueueAssembly.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07.04.2022.
//

import Foundation
import PaltaLibCore

final class EventQueueAssembly: FunctionalExtension {
    let sessionManager: SessionManagerImpl

    let eventQueueCore: EventQueueCoreImpl
    let liveEventQueueCore: EventQueueCoreImpl

    let eventStorage: EventStorage

    let eventComposer: EventComposerImpl
    let eventSender: EventSenderImpl
    let eventQueue: EventQueueImpl
    
    let identityLogger: IdentityLogger
    let revenueLogger: RevenueLogger
    
    private init(
        sessionManager: SessionManagerImpl,
        eventQueueCore: EventQueueCoreImpl,
        liveEventQueueCore: EventQueueCoreImpl,
        eventStorage: EventStorage,
        eventComposer: EventComposerImpl,
        eventSender: EventSenderImpl,
        eventQueue: EventQueueImpl,
        identityLogger: IdentityLogger,
        revenueLogger: RevenueLogger
    ) {
        self.sessionManager = sessionManager
        self.eventQueueCore = eventQueueCore
        self.liveEventQueueCore = liveEventQueueCore
        self.eventStorage = eventStorage
        self.eventComposer = eventComposer
        self.eventSender = eventSender
        self.eventQueue = eventQueue
        self.identityLogger = identityLogger
        self.revenueLogger = revenueLogger
    }
}

extension EventQueueAssembly {
    convenience init(coreAssembly: CoreAssembly, analyticsCoreAssembly: AnalyticsCoreAssembly) {
        let eventQueueCore = EventQueueCoreImpl(timer: TimerImpl())

        let liveEventQueueCore = EventQueueCoreImpl(timer: ImmediateTimer()).do {
            $0.apply(
                EventQueueConfig(
                    maxBatchSize: 5,
                    uploadInterval: 0,
                    uploadThreshold: 3,
                    maxEvents: 100,
                    maxConcurrentOperations: .max
                )
            )
        }

        let eventStorage: EventStorage = FileEventStorage()

        let eventComposer = EventComposerImpl(
            sessionIdProvider: analyticsCoreAssembly.sessionManager,
            userPropertiesProvider: analyticsCoreAssembly.userPropertiesKeeper,
            deviceInfoProvider: DeviceInfoProviderImpl(),
            trackingOptionsProvider: analyticsCoreAssembly.trackingOptionsProvider
        )

        let eventSender = EventSenderImpl(httpClient: coreAssembly.httpClient)

        let eventQueue = EventQueueImpl(
            core: eventQueueCore,
            liveCore: liveEventQueueCore,
            storage: eventStorage,
            sender: eventSender,
            eventComposer: eventComposer,
            sessionManager: analyticsCoreAssembly.sessionManager,
            timer: TimerImpl()
        )

        let identityLogger = IdentityLogger(eventQueue: eventQueue)

        let revenueLogger = RevenueLogger(eventQueue: eventQueue)
        
        self.init(
            sessionManager: analyticsCoreAssembly.sessionManager,
            eventQueueCore: eventQueueCore,
            liveEventQueueCore: liveEventQueueCore,
            eventStorage: eventStorage,
            eventComposer: eventComposer,
            eventSender: eventSender,
            eventQueue: eventQueue,
            identityLogger: identityLogger,
            revenueLogger: revenueLogger
        )
    }
}
