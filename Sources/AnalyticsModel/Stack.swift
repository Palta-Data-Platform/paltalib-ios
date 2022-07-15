//
//  Stack.swift
//  PaltaLibAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation

public struct Stack {
    public let batchCommon: BatchCommon.Type
    public let context: BatchContext.Type
    public let batch: Batch.Type
    public let event: BatchEvent.Type
    
    public let sessionStartEventType: EventType
    public let eventHeader: EventHeader.Type
    public let sessionStartEventPayload: SessionStartEventPayload.Type
    
    public init(
        batchCommon: BatchCommon.Type,
        context: BatchContext.Type,
        batch: Batch.Type,
        event: BatchEvent.Type,
        sessionStartEventType: EventType,
        eventHeader: EventHeader.Type,
        sessionStartEventPayload: SessionStartEventPayload.Type
    ) {
        self.batchCommon = batchCommon
        self.context = context
        self.batch = batch
        self.event = event
        self.sessionStartEventType = sessionStartEventType
        self.eventHeader = eventHeader
        self.sessionStartEventPayload = sessionStartEventPayload
    }
}
