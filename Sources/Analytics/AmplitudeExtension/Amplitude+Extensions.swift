//
//  Amplitude+Extensions.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 26.04.2022.
//

import Foundation
import Amplitude

extension Amplitude {
    private static var excludedEventKey = ""

    var excludedEvents: Set<String> {
        get {
            objc_getAssociatedObject(self, &Amplitude.excludedEventKey) as? Set<String> ?? []
        }
        set {
            objc_setAssociatedObject(self, &Amplitude.excludedEventKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func pb_logEvent(
        eventType: String,
        eventProperties: [AnyHashable: Any]? = nil,
        groups: [AnyHashable: Any]? = nil,
        timestamp: NSNumber? = nil,
        outOfSession: Bool = false
    ) {
        guard !excludedEvents.contains(eventType) else {
            return
        }

        if let timestamp = timestamp {
            logEvent(
                eventType,
                withEventProperties: eventProperties,
                withGroups: groups,
                withTimestamp: timestamp,
                outOfSession: outOfSession
            )
        } else {
            logEvent(
                eventType,
                withEventProperties: eventProperties,
                withGroups: groups,
                outOfSession: outOfSession
            )
        }
    }
}
