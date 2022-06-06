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
    
    func apply(_ target: ConfigTarget) {
        let settings = target.settings
        trackingSessionEvents = settings.trackingSessionEvents
        eventMaxCount = Int32(settings.eventMaxCount)
        eventUploadMaxBatchSize = Int32(settings.eventUploadMaxBatchSize)
        eventUploadPeriodSeconds = Int32(settings.eventUploadPeriodSeconds)
        eventUploadThreshold = Int32(settings.eventUploadThreshold)
        minTimeBetweenSessionsMillis = settings.minTimeBetweenSessionsMillis
        excludedEvents = settings.excludedEventTypes
        
        if let url = target.url {
            setServerUrl(url.absoluteString)
        }
    }
}
