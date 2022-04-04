//
//  EventQueue.swift
//  
//
//  Created by Vyacheslav Beltyukov on 31.03.2022.
//

import Foundation

final class EventQueue {
    private let core: EventQueueCore
    private let storage: EventStorage
    private let sender: EventSender
    private let eventComposer: EventComposer
    private let timer: Timer

    init(
        core: EventQueueCore,
        storage: EventStorage,
        sender: EventSender,
        eventComposer: EventComposer,
        timer: Timer
    ) {
        self.core = core
        self.storage = storage
        self.sender = sender
        self.eventComposer = eventComposer
        self.timer = timer

        setupCore()
    }

    func logEvent(
        eventType: String,
        eventProperties: [String: Any],
        groups: [String: Any],
        timestamp: Int? = nil
    ) {
        let event = eventComposer.composeEvent(
            eventType: eventType,
            eventProperties: eventProperties,
            groups: groups,
            timestamp: timestamp
        )

        storage.storeEvent(event)
        core.addEvent(event)
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
