//
//  EventStorageMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class EventStorageMock: EventStorage {
    var storedEvents: [StorableEvent] = []
    var removedIds: [UUID] = []
    var loadedEvents: [StorableEvent] = []
    
    func storeEvent(_ event: StorableEvent) {
        storedEvents.append(event)
    }
    
    func removeEvent(with id: UUID) {
        removedIds.append(id)
    }
    
    func loadEvents(_ completion: @escaping ([StorableEvent]) -> Void) {
        completion(loadedEvents)
    }
}
