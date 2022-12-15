//
//  EventQueueCoreMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class EventQueueCoreMock: EventQueueCore {
    var sendHandler: UploadHandler?
    var removeHandler: RemoveHandler?

    var addedEvents: [Event] = []
    
    var sendEventsTriggered = false
    var forceFlushTriggered = false

    func addEvent(_ event: Event) {
        addedEvents.append(event)
    }

    func addEvents(_ events: [Event]) {
        addedEvents.append(contentsOf: events)
    }
    
    func sendEventsAvailable() {
        sendEventsTriggered = true
    }
    
    func forceFlush() {
        forceFlushTriggered = true
    }
}
