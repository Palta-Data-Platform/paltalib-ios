//
//  EventQueue2Assembly.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaLibCore

final class EventQueue2Assembly {
    let eventQueue: EventQueue2Impl
    let eventQueueCore: EventQueueCore2Impl
    let batchSender: BatchSenderImpl
    let contextModifier: ContextModifier
    
    init(
        eventQueue: EventQueue2Impl,
        eventQueueCore: EventQueueCore2Impl,
        batchSender: BatchSenderImpl,
        contextModifier: ContextModifier
    ) {
        self.eventQueue = eventQueue
        self.eventQueueCore = eventQueueCore
        self.batchSender = batchSender
        self.contextModifier = contextModifier
    }
}

extension EventQueue2Assembly {
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
        
        let core = EventQueueCore2Impl(timer: TimerImpl())
        
        let eventComposer = EventComposer2Impl(
            stack: stack,
            sessionIdProvider: analyticsCoreAssembly.sessionManager
        )
        
        // Storages
        
        let eventStorage = EventStorage2Impl(
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
            deviceInfoProvider: DeviceInfoProviderImpl()
        )
        
        let sdkInfoProvider = SDKInfoProviderImpl()
        
        let batchSender = BatchSenderImpl(
            httpClient: coreAssembly.httpClient,
            sdkInfoProvider: sdkInfoProvider
        )
        
        let sendController = BatchSendControllerImpl(
            batchComposer: batchComposer,
            batchStorage: batchStorage,
            batchSender: batchSender,
            eventStorage: eventStorage,
            timer: TimerImpl()
        )
        
        // EventQueue
        
        let eventQueue = EventQueue2Impl(
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
