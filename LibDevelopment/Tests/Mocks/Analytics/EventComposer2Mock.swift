//
//  EventComposer2Mock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class EventComposer2Mock: EventComposer2 {
    var shouldFailSerialize = false
    var shouldFailDeserialize = false
    
    func composeEvent(of type: EventTypeBox, with header: EventHeader, and payload: EventPayload) -> BatchEvent {
        BatchEventMock(shouldFailSerialize: shouldFailSerialize, shouldFailDeserialize: shouldFailDeserialize)
    }
}
