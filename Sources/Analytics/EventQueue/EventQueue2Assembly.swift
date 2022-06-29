//
//  EventQueue2Assembly.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaLibCore

final class EventQueue2Assembly {
    internal init(eventQueue: EventQueue2Impl, eventQueueCore: EventQueueCore2Impl, batchSender: BatchSenderImpl) {
        self.eventQueue = eventQueue
        self.eventQueueCore = eventQueueCore
        self.batchSender = batchSender
    }
    
    let eventQueue: EventQueue2Impl
    let eventQueueCore: EventQueueCore2Impl
    let batchSender: BatchSenderImpl
}

extension EventQueue2Assembly {
    convenience init(
        stack: Stack,
        coreAssembly: CoreAssembly,
        analyticsCoreAssembly: AnalyticsCoreAssembly
    ) {
        let core = EventQueueCore2Impl(timer: TimerImpl())
        let eventStorage = EventStorage2Impl(
            folderURL: URL(string: "")!,
            stack: stack,
            fileManager: .default
        )
        
        let eventComposer = EventComposer2Impl(
            stack: stack,
            sessionIdProvider: analyticsCoreAssembly.sessionManager
        )
        
//        let contextHolder:  = ContextHolderImpl(stack: stack)
        let batchComposer: BatchComposer = { fatalError() } ()
//        BatchComposerImpl(stack: stack, contextHolder: contextHolder)
        
        let batchStorage = BatchStorageImpl(
            folderURL: URL(string: "")!,
            stack: stack,
            fileManager: .default
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
        
        let eventQueue = EventQueue2Impl(
            core: core,
            storage: eventStorage,
            sendController: sendController,
            eventComposer: eventComposer,
            sessionManager: analyticsCoreAssembly.sessionManager,
            contextProvider: { fatalError() }()
        )
        
        self.init(eventQueue: eventQueue, eventQueueCore: core, batchSender: batchSender)
    }
}
