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
    var liveEventTypes: Set<String> = []

    private let core: EventQueueCore
    private let liveCore: EventQueueCore
    private let storage: EventStorage
    private let sender: EventSender
    private let eventComposer: EventComposer
    private let sessionManager: SessionManager
    private let timer: Timer

    init(
        core: EventQueueCore,
        liveCore: EventQueueCore,
        storage: EventStorage,
        sender: EventSender,
        eventComposer: EventComposer,
        sessionManager: SessionManager,
        timer: Timer
    ) {
        self.core = core
        self.liveCore = liveCore
        self.storage = storage
        self.sender = sender
        self.eventComposer = eventComposer
        self.sessionManager = sessionManager
        self.timer = timer

        setupCore(core, loadEvents: true)
        setupCore(liveCore, loadEvents: false)
        startSessionManager()
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

        if !outOfSession {
            sessionManager.refreshSession(with: event)
        }
    }

    private func setupCore(_ core: EventQueueCore, loadEvents: Bool) {
        core.sendHandler = { [weak self] events, completionHandler in
            self?.sendEvents(Array(events), completionHandler)
        }

        core.removeHandler = { [storage] in
            $0.forEach(storage.removeEvent)
        }

        guard loadEvents else {
            return
        }

        storage.loadEvents { [core] events in
            core.addEvents(events)
        }
    }

    private func startSessionManager() {
        sessionManager.sessionEventLogger = { [weak self] eventName, timestamp in
            self?.logEvent(
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

    private func sendEvents(_ events: [Event], _ completionHandler: @escaping () -> Void) {
        sender.sendEvents(events) { [core, storage, timer] result in
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
}
