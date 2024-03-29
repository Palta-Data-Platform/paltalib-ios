//
//  EventQueue.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel

protocol EventQueue {
    func logEvent<E: Event>(_ incomingEvent: E)
}

final class EventQueueImpl: EventQueue {
    private let stack: Stack
    private let core: EventQueueCore
    private let storage: EventStorage
    private let sendController: BatchSendController
    private let eventComposer: EventComposer
    private let sessionManager: SessionManager
    private let contextProvider: CurrentContextProvider
    private let backgroundNotifier: BackgroundNotifier

    init(
        stack: Stack,
        core: EventQueueCore,
        storage: EventStorage,
        sendController: BatchSendController,
        eventComposer: EventComposer,
        sessionManager: SessionManager,
        contextProvider: CurrentContextProvider,
        backgroundNotifier: BackgroundNotifier
    ) {
        self.stack = stack
        self.core = core
        self.storage = storage
        self.sendController = sendController
        self.eventComposer = eventComposer
        self.sessionManager = sessionManager
        self.contextProvider = contextProvider
        self.backgroundNotifier = backgroundNotifier

        setupCore(core, liveQueue: false)
        setupSendController()
        startSessionManager()
        subscribeForBackgroundNotifications()
    }
    
    func logEvent<E: Event>(_ incomingEvent: E) {
        logEvent(
            of: incomingEvent.type,
            with: incomingEvent.header,
            and: incomingEvent.payload,
            timestamp: nil,
            skipRefreshSession: false
        )
    }
    
    private func logEvent(
        of type: EventType,
        with header: EventHeader?,
        and payload: EventPayload,
        timestamp: Int?,
        skipRefreshSession: Bool
    ) {
        if !skipRefreshSession {
            sessionManager.refreshSession(with: currentTimestamp())
        }

        let event = eventComposer.composeEvent(
            of: type,
            with: header,
            and: payload,
            timestamp: timestamp
        )
        
        let storableEvent = StorableEvent(
            event: IdentifiableEvent(id: UUID(), event: event),
            contextId: contextProvider.currentContextId
        )
        
        storage.storeEvent(storableEvent)
        core.addEvent(storableEvent)
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
        sessionManager.sessionStartLogger = { [weak self] timestamp in
            guard let self = self else {
                return
            }
            
            self.logEvent(
                of: self.stack.sessionStartEventType,
                with: nil,
                and: self.stack.sessionStartEventPayloadProvider(),
                timestamp: timestamp,
                skipRefreshSession: true
            )
        }
        
        sessionManager.start()
    }
    
    private func subscribeForBackgroundNotifications() {
        backgroundNotifier.addListener { [weak self] in
            self?.core.forceFlush()
        }
    }
}

