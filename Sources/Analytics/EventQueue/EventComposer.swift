//
//  EventComposer.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation
import PaltaLibCore

protocol EventComposer {
    func composeEvent(
        eventType: String,
        eventProperties: [String: Any],
        groups: [String: Any],
        timestamp: Int?
    ) -> Event
}

final class EventComposerImpl: EventComposer {
    func composeEvent(
        eventType: String,
        eventProperties: [String: Any],
        groups: [String: Any],
        timestamp: Int?
    ) -> Event {
        let timestamp = timestamp ?? Int(Date().timeIntervalSince1970 * 1000)

        return Event(
            eventType: eventType,
            eventProperties: CodableDictionary(eventProperties),
            apiProperties: [:],
            userProperties: [:],
            groups: CodableDictionary(groups),
            groupProperties: [:],
            sessionId: 0,
            timestamp: timestamp
        )
    }
}
