//
//  Stack.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation

public struct Stack {
    let batchCommon: BatchCommon.Type
    let context: BatchContext.Type
    let batch: Batch.Type
    let event: BatchEvent.Type
    
    let sessionStartEventType: EventType
    let eventHeader: EventHeader.Type
    let sessionStartEventPayload: SessionStartEventPayload.Type
    
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
