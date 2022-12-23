//
//  EventQueue.swift
//  
//
//  Created by Vyacheslav Beltyukov on 31.03.2022.
//

import Foundation

protocol EventQueue {
    func logEvent(
        eventType: String,
        eventProperties: [String: Any],
        apiProperties: [String: Any],
        groups: [String: Any],
        userProperties: [String: Any],
        groupProperties: [String: Any],
        timestamp: Int?,
        outOfSession: Bool
    )
}

final class EventQueueImpl: EventQueue {
    var trackingSessionEvents = true
    var liveEventTypes: Set<String> = []
    var excludedEvents: Set<String> = []

    private let core: EventQueueCore
//    private let liveCore: EventQueueCore
    private let storage: EventStorage
    private let sendController: BatchSendController
    private let eventComposer: EventComposer
    private let sessionManager: SessionManager
    private let timer: Timer
    private let backgroundNotifier: BackgroundNotifier

    init(
        core: EventQueueCore,
//        liveCore: EventQueueCore,
        storage: EventStorage,
        sendController: BatchSendController,
        eventComposer: EventComposer,
        sessionManager: SessionManager,
        timer: Timer,
        backgroundNotifier: BackgroundNotifier
    ) {
        self.core = core
//        self.liveCore = liveCore
        self.storage = storage
        self.sendController = sendController
        self.eventComposer = eventComposer
        self.sessionManager = sessionManager
        self.timer = timer
        self.backgroundNotifier = backgroundNotifier

        setupSendController()
        setupCore(core, liveQueue: false)
//        setupCore(liveCore, liveQueue: true)
        startSessionManager()
        subscribeForBackgroundNotifications()
    }
    
    func logEvent(
        eventType: String,
        eventProperties: [String: Any],
        apiProperties: [String: Any] = [:],
        groups: [String: Any],
        userProperties: [String: Any] = [:],
        groupProperties: [String: Any] = [:],
        timestamp: Int? = nil,
        outOfSession: Bool = false
    ) {
        doLogEvent(
            eventType: eventType,
            eventProperties: eventProperties,
            apiProperties: apiProperties,
            groups: groups,
            userProperties: userProperties,
            groupProperties: groupProperties,
            timestamp: timestamp,
            sessionId: outOfSession ? -1 : nil,
            outOfSession: outOfSession
        )
    }

    private func doLogEvent(
        eventType: String,
        eventProperties: [String: Any],
        apiProperties: [String: Any],
        groups: [String: Any],
        userProperties: [String: Any],
        groupProperties: [String: Any],
        timestamp: Int?,
        sessionId: Int?,
        outOfSession: Bool
    ) {
        guard !excludedEvents.contains(eventType) else {
            return
        }
        
        if !outOfSession {
            sessionManager.refreshSession(with: timestamp ?? .currentTimestamp())
        }

        let event = eventComposer.composeEvent(
            eventType: eventType,
            eventProperties: eventProperties,
            apiProperties: apiProperties,
            groups: groups,
            userProperties: userProperties,
            groupProperties: groupProperties,
            timestamp: timestamp,
            sessionId: sessionId
        )

        storage.storeEvent(event)

//        if liveEventTypes.contains(eventType) {
//            liveCore.addEvent(event)
//        } else {
            core.addEvent(event)
//        }
    }
    
    private func setupSendController() {
        sendController.isReadyCallback = { [core] in
            core.sendEventsAvailable()
        }
    }

    private func setupCore(_ core: EventQueueCore, liveQueue: Bool) {
        core.sendHandler = { [weak self] events, telemetry in
            guard let self = self, self.sendController.isReady else {
                return false
            }
            
            self.sendController.sendBatch(of: Array(events), with: telemetry)
            return true
        }

        core.removeHandler = { [weak self] in
            guard let self = self else { return }

            $0.forEach {
                self.storage.removeEvent($0)
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
        sessionManager.sessionEventLogger = { [weak self] eventName, timestamp in
            guard let self = self, self.trackingSessionEvents else {
                return
            }
            
            self.doLogEvent(
                eventType: eventName,
                eventProperties: [:],
                apiProperties: ["special": eventName],
                groups: [:],
                userProperties: [:],
                groupProperties: [:],
                timestamp: timestamp,
                sessionId: timestamp,
                outOfSession: true
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
