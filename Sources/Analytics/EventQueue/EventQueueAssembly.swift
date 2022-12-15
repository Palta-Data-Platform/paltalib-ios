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
    let batchSendController: BatchSendControllerImpl
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
        batchSendController: BatchSendControllerImpl,
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
        self.batchSendController = batchSendController
        self.eventQueue = eventQueue
        self.identityLogger = identityLogger
        self.revenueLogger = revenueLogger
    }
}

extension EventQueueAssembly {
    convenience init(coreAssembly: CoreAssembly, analyticsCoreAssembly: AnalyticsCoreAssembly) throws {
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

        let storage = try SQLiteStorage(folderURL: folderURL)
        
        do {
            let migrator = FileStorageMigrator(folderURL: folderURL, newStorage: storage)
            try migrator.migrateEvents()
        } catch {
            print("PaltaLib: Analytics: Error migrating events from legacy storage: \(error.localizedDescription)")
        }

        let eventComposer = EventComposerImpl(
            sessionIdProvider: analyticsCoreAssembly.sessionManager,
            userPropertiesProvider: analyticsCoreAssembly.userPropertiesKeeper,
            deviceInfoProvider: DeviceInfoProviderImpl(),
            trackingOptionsProvider: analyticsCoreAssembly.trackingOptionsProvider
        )
        
        let batchSender = BatchSenderImpl(httpClient: coreAssembly.httpClient)
        
        let batchSendController = BatchSendControllerImpl(
            batchComposer: BatchComposerImpl(),
            batchStorage: storage,
            batchSender: batchSender,
            timer: TimerImpl()
        )

        let eventQueue = EventQueueImpl(
            core: eventQueueCore,
            storage: storage,
            sendController: batchSendController,
            eventComposer: eventComposer,
            sessionManager: analyticsCoreAssembly.sessionManager,
            timer: TimerImpl(),
            backgroundNotifier: BackgroundNotifierImpl(notificationCenter: .default)
        )

        let identityLogger = IdentityLogger(eventQueue: eventQueue)

        let revenueLogger = RevenueLogger(eventQueue: eventQueue)
        
        self.init(
            sessionManager: analyticsCoreAssembly.sessionManager,
            eventQueueCore: eventQueueCore,
            liveEventQueueCore: liveEventQueueCore,
            eventStorage: storage,
            eventComposer: eventComposer,
            batchSender: batchSender,
            batchSendController: batchSendController,
            eventQueue: eventQueue,
            identityLogger: identityLogger,
            revenueLogger: revenueLogger
        )
    }
}
