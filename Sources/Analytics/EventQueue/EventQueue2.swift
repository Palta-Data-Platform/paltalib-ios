//
//  EventQueue2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation

protocol EventQueue2 {
    func logEvent<Event: Event2>(_ incomingEvent: Event, outOfSession: Bool)
}

final class EventQueue2Impl: EventQueue2 {
    var trackingSessionEvents = true
//    var liveEventTypes: Set<String> = []

    private let core: EventQueueCore2
    private let storage: EventStorage2
    private let sendController: BatchSendController
    private let eventComposer: EventComposer2
    private let sessionManager: SessionManager
    private let contextProvider: CurrentContextProvider

    init(
        core: EventQueueCore2,
        storage: EventStorage2,
        sendController: BatchSendController,
        eventComposer: EventComposer2,
        sessionManager: SessionManager,
        contextProvider: CurrentContextProvider
    ) {
        self.core = core
        self.storage = storage
        self.sendController = sendController
        self.eventComposer = eventComposer
        self.sessionManager = sessionManager
        self.contextProvider = contextProvider

        setupCore(core, liveQueue: false)
        setupSendController()
        startSessionManager()
    }
    
    func logEvent<Event: Event2>(_ incomingEvent: Event, outOfSession: Bool) {
        let event = eventComposer.composeEvent(
            of: incomingEvent.type.boxed,
            with: incomingEvent.header,
            and: incomingEvent.payload
        )
        
        let storableEvent = StorableEvent(
            event: IdentifiableEvent(id: UUID(), event: event),
            contextId: contextProvider.currentContextId
        )
        
        storage.storeEvent(storableEvent)
        core.addEvent(storableEvent)
        
        if !outOfSession {
            sessionManager.refreshSession(with: event)
        }
    }
    
    private func setupSendController() {
        sendController.isReadyCallback = { [core] in
            core.sendEventsAvailable()
        }
    }

    private func setupCore(_ core: EventQueueCore2, liveQueue: Bool) {
        core.sendHandler = { [weak self] events, contextId, _ in
            guard let self = self, self.sendController.isReady else {
                return false
            }
            
            self.sendController.sendBatch(of: Array(events), with: contextId)
            return true
        }

        core.removeHandler = { [weak self] in
            guard let self = self else { return }

            $0.forEach(self.storage.removeEvent)
        }

        guard !liveQueue else {
            return
        }

        storage.loadEvents { [core] events in
            core.addEvents(events)
        }
    }

    private func startSessionManager() {
        sessionManager.start()
    }
}

