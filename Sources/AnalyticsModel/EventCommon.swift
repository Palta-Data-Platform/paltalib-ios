//
//  EventCommon.swift
//  PaltaLibAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public struct EventCommon {
    public let eventType: EventType
    public let timestamp: Int
    public let sessionId: Int
    
    public init(eventType: EventType, timestamp: Int, sessionId: Int) {
        self.eventType = eventType
        self.timestamp = timestamp
        self.sessionId = sessionId
    }
}
