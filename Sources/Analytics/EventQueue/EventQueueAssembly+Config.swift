//
//  EventQueueAssembly+Config.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 18/05/2022.
//

import Foundation

extension EventQueueAssembly {
    func apply(_ target: ConfigTarget, host: URL?) {
        let normalConfig = EventQueueConfig(
            maxBatchSize: target.settings.eventUploadMaxBatchSize,
            uploadInterval: TimeInterval(target.settings.eventUploadPeriodSeconds),
            uploadThreshold: target.settings.eventUploadThreshold,
            maxEvents: target.settings.eventMaxCount
        )
        
        let liveConfig = EventQueueConfig(
            maxBatchSize: target.settings.eventUploadMaxBatchSize,
            uploadInterval: 0,
            uploadThreshold: 0,
            maxEvents: target.settings.eventMaxCount
        )
        
        eventQueueCore.apply(normalConfig)
        liveEventQueueCore.apply(liveConfig)

        eventQueue.trackingSessionEvents = target.settings.trackingSessionEvents
        eventQueue.liveEventTypes = target.settings.realtimeEventTypes
        eventQueue.excludedEvents = target.settings.excludedEventTypes
        
        batchSender.baseURL = host

        sessionManager.maxSessionAge = target.settings.minTimeBetweenSessionsMillis
    }
}
