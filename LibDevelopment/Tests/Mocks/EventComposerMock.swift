//
//  EventComposerMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation

final class EventComposerMock: EventComposer {
    var eventType: String?
    var eventProperties: [String : Any]?
    var groups: [String : Any]?
    var timestamp: Int?

    func composeEvent(eventType: String, eventProperties: [String : Any], groups: [String : Any], timestamp: Int?) -> Event {
        self.eventType = eventType
        self.eventProperties = eventProperties
        self.groups = groups
        self.timestamp = timestamp
        
        return .mock()
    }
}
