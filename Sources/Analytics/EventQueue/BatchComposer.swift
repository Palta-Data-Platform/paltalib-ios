//
//  BatchComposer.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public struct Stack {
    public let batchCommon: BatchCommon.Type
    public let batch: Batch.Type
    public let event: BatchEvent.Type
}

protocol BatchComposer {
    func makeBatch(of events: [BatchEvent], with context: BatchContext) throws -> Batch
}

final class BatchComposerImpl: BatchComposer {
    private let stack: Stack
    private let batchStorage: BatchStorage
    private let eventStorage: EventStorage2
    
    init(stack: Stack, batchStorage: BatchStorage, eventStorage: EventStorage2) {
        self.stack = stack
        self.batchStorage = batchStorage
        self.eventStorage = eventStorage
    }
    
    func makeBatch(of events: [BatchEvent], with context: BatchContext) throws -> Batch {
        let common = stack.batchCommon.init(
            instanceId: .init(), // TODO
            batchId: .init(), // TODO
            countryCode: "",
            locale: .current,
            utcOffset: 0
        )
        
        let batch = stack.batch.init(common: common, context: context, events: events)
        
        events.forEach(eventStorage.removeEvent)
        try batchStorage.saveBatch(batch)
        
        return batch
    }
}
