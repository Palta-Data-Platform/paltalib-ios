//
//  EventQueue.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation

protocol EventQueue {
    func logEvent<E: Event>(_ incomingEvent: E, outOfSession: Bool)
}

final class EventQueueImpl: EventQueue {
    private let core: EventQueueCore
    private let storage: EventStorage
    private let sendController: BatchSendController
    private let eventComposer: EventComposer
    private let sessionManager: SessionManager
    private let contextProvider: CurrentContextProvider

    init(
        core: EventQueueCore,
        storage: EventStorage,
        sendController: BatchSendController,
        eventComposer: EventComposer,
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
    
    func logEvent<E: Event>(_ incomingEvent: E, outOfSession: Bool) {
        let event = eventComposer.composeEvent(
            of: incomingEvent.type,
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

    private func setupCore(_ core: EventQueueCore, liveQueue: Bool) {
        core.sendHandler = { [weak self] events, contextId, _ in
            guard let self = self, self.sendController.isReady else {
                return false
            }
            
            self.sendController.sendBatch(of: events, with: contextId)
            return true
        }

        core.removeHandler = { [weak self] in
            guard let self = self else { return }

            $0.forEach {
                self.storage.removeEvent(with: $0.event.id)
            }
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

