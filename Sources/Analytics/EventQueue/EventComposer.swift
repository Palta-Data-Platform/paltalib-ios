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
        timestamp: Int?,
        outOfSession: Bool
    ) -> BatchEvent
}

final class EventComposerImpl: EventComposer {
    private let stack: Stack
    private let sessionIdProvider: SessionIdProvider
    
    init(stack: Stack, sessionIdProvider: SessionIdProvider) {
        self.stack = stack
        self.sessionIdProvider = sessionIdProvider
    }
    
    func composeEvent(
        of type: EventType,
        with header: EventHeader?,
        and payload: EventPayload,
        timestamp: Int?,
        outOfSession: Bool
    ) -> BatchEvent {
        let common = EventCommon(
            eventType: type,
            timestamp: timestamp ?? currentTimestamp(),
            sessionId: outOfSession ? -1 : sessionIdProvider.sessionId
        )
        
        return stack.event.init(common: common, header: header, payload: payload)
    }
}
