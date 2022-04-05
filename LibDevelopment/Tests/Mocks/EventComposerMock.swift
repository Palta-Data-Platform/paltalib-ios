//
//  EventComposerMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class EventComposerMock: EventComposer {
    var eventType: String?
    var eventProperties: [String : Any]?
    var apiProperties: [String : Any]?
    var groups: [String : Any]?
    var timestamp: Int?

    func composeEvent(eventType: String, eventProperties: [String : Any], apiProperties: [String : Any], groups: [String : Any], timestamp: Int?) -> Event {
        self.eventType = eventType
        self.eventProperties = eventProperties
        self.apiProperties = apiProperties
        self.groups = groups
        self.timestamp = timestamp
        
        return .mock()
    }
}
