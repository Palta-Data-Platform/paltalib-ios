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
    let batchSender: BatchSenderImpl
    let eventQueue: EventQueueImpl
    
    let identityLogger: IdentityLogger
    let revenueLogger: RevenueLogger
    
    private init(
        sessionManager: SessionManagerImpl,
        eventQueueCore: EventQueueCoreImpl,
        liveEventQueueCore: EventQueueCoreImpl,
        eventStorage: EventStorage,
        eventComposer: EventComposerImpl,
        batchSender: BatchSenderImpl,
        eventQueue: EventQueueImpl,
        identityLogger: IdentityLogger,
        revenueLogger: RevenueLogger
    ) {
        self.sessionManager = sessionManager
        self.eventQueueCore = eventQueueCore
        self.liveEventQueueCore = liveEventQueueCore
        self.eventStorage = eventStorage
        self.eventComposer = eventComposer
        self.batchSender = batchSender
        self.eventQueue = eventQueue
        self.identityLogger = identityLogger
        self.revenueLogger = revenueLogger
    }
}

extension EventQueueAssembly {
    convenience init(coreAssembly: CoreAssembly, analyticsCoreAssembly: AnalyticsCoreAssembly) {
        let folderURL = try! FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("PaltaBrainEvents")
        
        let eventQueueCore = EventQueueCoreImpl(timer: TimerImpl())

        let liveEventQueueCore = EventQueueCoreImpl(timer: ImmediateTimer()).do {
            $0.apply(
                EventQueueConfig(
                    maxBatchSize: 5,
                    uploadInterval: 0,
                    uploadThreshold: 3,
                    maxEvents: 100
                )
            )
        }

        let eventStorage: EventStorage = FileEventStorage(folderURL: folderURL)

        let eventComposer = EventComposerImpl(
            sessionIdProvider: analyticsCoreAssembly.sessionManager,
            userPropertiesProvider: analyticsCoreAssembly.userPropertiesKeeper,
            deviceInfoProvider: DeviceInfoProviderImpl(),
            trackingOptionsProvider: analyticsCoreAssembly.trackingOptionsProvider
        )
        
        let batchStorage = BatchStorageImpl(folderURL: folderURL, fileManager: .default)
        let batchSender = BatchSenderImpl(httpClient: coreAssembly.httpClient)
        
        let batchSendController = BatchSendControllerImpl(
            batchComposer: BatchComposerImpl(),
            batchStorage: batchStorage,
            batchSender: batchSender,
            eventStorage: eventStorage,
            timer: TimerImpl()
        )

        let eventQueue = EventQueueImpl(
            core: eventQueueCore,
            storage: eventStorage,
            sendController: batchSendController,
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
            batchSender: batchSender,
            eventQueue: eventQueue,
            identityLogger: identityLogger,
            revenueLogger: revenueLogger
        )
    }
}
