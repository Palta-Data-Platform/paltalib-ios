//
//  EventMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 15/07/2022.
//

import Foundation
import PaltaLibAnalyticsModel

final class EventMock: Event {
    typealias Header = EventHeaderMock
    typealias Payload = EventPayloadMock
    typealias EventType = Int
    
    var header: EventHeaderMock {
        EventHeaderMock()
    }
    
    var payload: EventPayloadMock {
        EventPayloadMock()
    }
    
    var type: Int {
        0
    }
}
