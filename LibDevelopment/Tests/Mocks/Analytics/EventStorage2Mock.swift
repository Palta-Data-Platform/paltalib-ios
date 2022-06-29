//
//  EventStorage2Mock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class EventStorage2Mock: EventStorage2 {
    var storedEvents: [StorableEvent] = []
    var removedEvents: [StorableEvent] = []
    var loadedEvents: [StorableEvent] = []
    
    func storeEvent(_ event: StorableEvent) {
        storedEvents.append(event)
    }
    
    func removeEvent(_ event: StorableEvent) {
        removedEvents.append(event)
    }
    
    func loadEvents(_ completion: @escaping ([StorableEvent]) -> Void) {
        completion(loadedEvents)
    }
}
