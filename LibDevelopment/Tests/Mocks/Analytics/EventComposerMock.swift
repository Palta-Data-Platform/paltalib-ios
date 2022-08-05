//
//  EventComposerMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class EventComposerMock: EventComposer {
    var shouldFailSerialize = false
    var shouldFailDeserialize = false
    
    var timestamp: Int?
    var isOutOfSession: Bool?
    
    func composeEvent(
        of type: EventType,
        with header: EventHeader,
        and payload: EventPayload,
        timestamp: Int?,
        outOfSession: Bool
    ) -> BatchEvent {
        self.timestamp = timestamp
        self.isOutOfSession = outOfSession
        
        return BatchEventMock(shouldFailSerialize: shouldFailSerialize, shouldFailDeserialize: shouldFailDeserialize)
    }
}
