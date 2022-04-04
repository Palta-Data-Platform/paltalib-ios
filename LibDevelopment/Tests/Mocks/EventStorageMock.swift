//
//  EventStorageMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation

final class EventStorageMock: EventStorage {
    var addedEvents: [Event] = []

    var removedEvents: [Event] = []

    var eventsToLoad: [Event] = []

    func storeEvent(_ event: Event) {
        addedEvents.append(event)
    }

    func removeEvent(_ event: Event) {
        removedEvents.append(event)
    }

    func loadEvents(_ completion: @escaping ([Event]) -> Void) {
        completion(eventsToLoad)
    }
}
