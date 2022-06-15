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
        let batchSender = BatchSenderImpl()
        let core = EventQueueCore2Impl(timer: TimerImpl())
        let storage = EventStorage2Impl()
        let sendController = BatchSendControllerImpl(
            batchSender: batchSender,
            stack: stack
        )
        let eventComposer = EventComposer2Impl(
            stack: stack,
            sessionIdProvider: analyticsCoreAssembly.sessionManager
        )
        
        let eventQueue = EventQueue2Impl(
            core: core,
            storage: storage,
            sendController: sendController,
            eventComposer: eventComposer,
            sessionManager: analyticsCoreAssembly.sessionManager
        )
        
        self.init(eventQueue: eventQueue, eventQueueCore: core, batchSender: batchSender)
    }
}
