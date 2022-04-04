//
//  EventQueueCoreMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation

final class EventQueueCoreMock: EventQueueCore {
    var sendHandler: UploadHandler?
    var removeHandler: RemoveHandler?

    var addedEvents: [Event] = []

    func addEvent(_ event: Event) {
        addedEvents.append(event)
    }

    func addEvents(_ events: [Event]) {
        addedEvents.append(contentsOf: events)
    }
}
