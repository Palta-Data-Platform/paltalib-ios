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
        groups: [String: Any],
        userProperties: [String: Any],
        groupProperties: [String: Any],
        timestamp: Int?,
        outOfSession: Bool
    )
}

final class EventQueueImpl: EventQueue {
    private let core: EventQueueCore
    private let storage: EventStorage
    private let sender: EventSender
    private let eventComposer: EventComposer
    private let sessionManager: SessionManager
    private let timer: Timer

    init(
        core: EventQueueCore,
        storage: EventStorage,
        sender: EventSender,
        eventComposer: EventComposer,
        sessionManager: SessionManager,
        timer: Timer
    ) {
        self.core = core
        self.storage = storage
        self.sender = sender
        self.eventComposer = eventComposer
        self.sessionManager = sessionManager
        self.timer = timer

        setupCore()
        startSessionManager()
    }

    func logEvent(
        eventType: String,
        eventProperties: [String: Any],
        groups: [String: Any],
        userProperties: [String: Any] = [:],
        groupProperties: [String: Any] = [:],
        timestamp: Int? = nil,
        outOfSession: Bool = false
    ) {
        let event = eventComposer.composeEvent(
            eventType: eventType,
            eventProperties: eventProperties,
            apiProperties: [:],
            groups: groups,
            userProperties: userProperties,
            groupProperties: groupProperties,
            timestamp: timestamp,
            outOfSession: outOfSession
        )

        storage.storeEvent(event)
        core.addEvent(event)
        sessionManager.refreshSession(with: event)
    }

    private func setupCore() {
        core.sendHandler = { [weak self] events, completionHandler in
            self?.sendEvents(Array(events), completionHandler)
        }

        core.removeHandler = { [storage] in
            $0.forEach(storage.removeEvent)
        }

        storage.loadEvents { [core] events in
            core.addEvents(events)
        }
    }

    private func startSessionManager() {
        sessionManager.sessionEventLogger = { [weak self] eventName, timestamp in
//            let event = Event(
//                eventType: eventName,
//                eventProperties: [:],
//                apiProperties: ["special": eventName],
//                userProperties: [:],
//                groups: [:],
//                groupProperties: [:],
//                sessionId: -1,
//                timestamp: timestamp
//            )
//
//            self?.core.addEvent(event)
//            self?.storage.storeEvent(event)
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
