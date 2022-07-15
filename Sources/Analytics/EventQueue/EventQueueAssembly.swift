//
//  EventQueueAssembly.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaLibCore

final class EventQueueAssembly {
    let eventQueue: EventQueueImpl
    let eventQueueCore: EventQueueCoreImpl
    let batchSender: BatchSenderImpl
    let contextModifier: ContextModifier
    
    init(
        eventQueue: EventQueueImpl,
        eventQueueCore: EventQueueCoreImpl,
        batchSender: BatchSenderImpl,
        contextModifier: ContextModifier
    ) {
        self.eventQueue = eventQueue
        self.eventQueueCore = eventQueueCore
        self.batchSender = batchSender
        self.contextModifier = contextModifier
    }
}

extension EventQueueAssembly {
    convenience init(
        stack: Stack,
        coreAssembly: CoreAssembly,
        analyticsCoreAssembly: AnalyticsCoreAssembly
    ) {
        let workingUrl = try! FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("PaltaDataPlatform")
        
        if !FileManager.default.fileExists(atPath: workingUrl.path) {
            try! FileManager.default.createDirectory(at: workingUrl, withIntermediateDirectories: true)
        }
        
        // Core
        
        let core = EventQueueCoreImpl(timer: TimerImpl())
        
        let eventComposer = EventComposerImpl(
            stack: stack,
            sessionIdProvider: analyticsCoreAssembly.sessionManager
        )
        
        // Storages
        
        let eventStorage = EventStorageImpl(
            folderURL: workingUrl,
            stack: stack,
            fileManager: .default
        )
        
        let contextStorage = ContextStorageImpl(
            folderURL: workingUrl,
            stack: stack,
            fileManager: .default
        )
        
        let batchStorage = BatchStorageImpl(
            folderURL: workingUrl,
            stack: stack,
            fileManager: .default
        )
        
        // Context
        
        let currentContextManager = CurrentContextManager(stack: stack, storage: contextStorage)
        
        // Batches
        
        let batchComposer = BatchComposerImpl(
            stack: stack,
            uuidGenerator: UUIDGeneratorImpl(),
            contextProvider: contextStorage,
            userInfoProvider: analyticsCoreAssembly.userPropertiesKeeper,
            deviceInfoProvider: analyticsCoreAssembly.deviceInfoProvider
        )
        
        let batchSender = BatchSenderImpl(
            httpClient: coreAssembly.httpClient
        )
        
        let sendController = BatchSendControllerImpl(
            batchComposer: batchComposer,
            batchStorage: batchStorage,
            batchSender: batchSender,
            eventStorage: eventStorage,
            timer: TimerImpl()
        )
        
        // EventQueue
        
        let eventQueue = EventQueueImpl(
            stack: stack,
            core: core,
            storage: eventStorage,
            sendController: sendController,
            eventComposer: eventComposer,
            sessionManager: analyticsCoreAssembly.sessionManager,
            contextProvider: currentContextManager
        )
        
        self.init(
            eventQueue: eventQueue,
            eventQueueCore: core,
            batchSender: batchSender,
            contextModifier: currentContextManager
        )
    }
}
