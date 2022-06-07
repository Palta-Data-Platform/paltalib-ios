//
//  EventComposer2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation

protocol EventComposer2 {
    func composeEvent(
        of type: EventTypeBox,
        with header: EventHeader,
        and payload: EventPayload
    ) -> BatchEvent
}

final class EventComposer2Impl: EventComposer2 {
    private let stack: Stack
    private let sessionIdProvider: SessionIdProvider
    
    init(stack: Stack, sessionIdProvider: SessionIdProvider) {
        self.stack = stack
        self.sessionIdProvider = sessionIdProvider
    }
    
    func composeEvent(
        of type: EventTypeBox,
        with header: EventHeader,
        and payload: EventPayload
    ) -> BatchEvent {
        let common = EventCommon(
            eventType: type,
            timestamp: currentTimestamp(),
            sessionId: sessionIdProvider.sessionId
        )
        
        return stack.event.init(common: common, header: header, payload: payload)
    }
}
