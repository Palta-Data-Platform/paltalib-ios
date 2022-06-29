//
//  EventQueue2CoreMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class EventQueue2CoreMock: EventQueueCore2 {
    var sendHandler: UploadHandler?
    var removeHandler: RemoveHandler?
    
    var addedEvents: [StorableEvent] = []
    var sendEventsTriggered = false
    
    func addEvent(_ event: StorableEvent) {
        addedEvents.append(event)
    }
    
    func addEvents(_ events: [StorableEvent]) {
        addedEvents.append(contentsOf: events)
    }
    
    func sendEventsAvailable() {
        sendEventsTriggered = true
    }
}
