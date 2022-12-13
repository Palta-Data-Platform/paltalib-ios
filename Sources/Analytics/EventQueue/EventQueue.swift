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
    private let liveCore: EventQueueCore
    private let storage: EventStorage
    private let sender: EventSender
    private let eventComposer: EventComposer
    private let sessionManager: SessionManager
    private let timer: Timer
    private let backgroundNotifier: BackgroundNotifier

    init(
        core: EventQueueCore,
        liveCore: EventQueueCore,
        storage: EventStorage,
        sender: EventSender,
        eventComposer: EventComposer,
        sessionManager: SessionManager,
        timer: Timer,
        backgroundNotifier: BackgroundNotifier
    ) {
        self.core = core
        self.liveCore = liveCore
        self.storage = storage
        self.sender = sender
        self.eventComposer = eventComposer
        self.sessionManager = sessionManager
        self.timer = timer
        self.backgroundNotifier = backgroundNotifier

        setupCore(core, liveQueue: false)
        setupCore(liveCore, liveQueue: true)
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
            outOfSession: outOfSession
        )

        storage.storeEvent(event)

        if liveEventTypes.contains(eventType) {
            liveCore.addEvent(event)
        } else {
            core.addEvent(event)
        }
    }

    private func setupCore(_ core: EventQueueCore, liveQueue: Bool) {
        core.sendHandler = { [weak self] events, telemetry, completionHandler in
            self?.sendEvents(
                Array(events),
                telemetry: liveQueue ? nil : telemetry,
                completionHandler
            )
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
        sessionManager.sessionEventLogger = { [weak self] eventName, timestamp in
            guard let self = self, self.trackingSessionEvents else {
                return
            }
            
            self.logEvent(
                eventType: eventName,
                eventProperties: [:],
                apiProperties: ["special": eventName],
                groups: [:],
                timestamp: timestamp,
                outOfSession: true
            )
        }

        sessionManager.start()
    }

    private func sendEvents(_ events: [Event], telemetry: Telemetry?, _ completionHandler: @escaping () -> Void) {
        sender.sendEvents(events, telemetry: telemetry) { [core, storage, timer] result in
            switch result {
            case .success:
                events.forEach(storage.removeEvent)
                completionHandler()

            case .failure(let error) where error.requiresRetry:
                core.addEvents(events)
                timer.scheduleTimer(timeInterval: 5, on: .global()) {
                    completionHandler()
                }

            case .failure:
                events.forEach(storage.removeEvent)
                completionHandler()
            }
            
        }
    }
    
    private func subscribeForBackgroundNotifications() {
        backgroundNotifier.addListener { [weak self] in
            self?.core.forceFlush()
        }
    }
}
