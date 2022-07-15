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
    
    func composeEvent(of type: EventType, with header: EventHeader, and payload: EventPayload) -> BatchEvent {
        BatchEventMock(shouldFailSerialize: shouldFailSerialize, shouldFailDeserialize: shouldFailDeserialize)
    }
}
