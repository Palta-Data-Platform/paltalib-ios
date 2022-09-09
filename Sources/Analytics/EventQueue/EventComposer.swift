//
//  EventComposer.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel

protocol EventComposer {
    func composeEvent(
        of type: EventType,
        with header: EventHeader?,
        and payload: EventPayload,
        timestamp: Int?
    ) -> BatchEvent
}

final class EventComposerImpl: EventComposer {
    private let stack: Stack
    private let sessionProvider: SessionProvider
    
    init(stack: Stack, sessionProvider: SessionProvider) {
        self.stack = stack
        self.sessionProvider = sessionProvider
    }
    
    func composeEvent(
        of type: EventType,
        with header: EventHeader?,
        and payload: EventPayload,
        timestamp: Int?
    ) -> BatchEvent {
        let common = EventCommon(
            eventType: type,
            timestamp: timestamp ?? currentTimestamp(),
            sessionId: sessionProvider.sessionId,
            sequenceNumber: sessionProvider.nextEventNumber()
        )
        
        return stack.event.init(common: common, header: header, payload: payload)
    }
}
