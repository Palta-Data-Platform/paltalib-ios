//
//  BatchComposer.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public struct Stack {
    let batchCommon: BatchCommon.Type
    let context: BatchContext.Type
    let batch: Batch.Type
    let event: BatchEvent.Type
    
    public init(
        batchCommon: BatchCommon.Type,
        context: BatchContext.Type,
        batch: Batch.Type,
        event: BatchEvent.Type
    ) {
        self.batchCommon = batchCommon
        self.context = context
        self.batch = batch
        self.event = event
    }
}

protocol BatchComposer {
    func makeBatch(of events: [BatchEvent]) -> Batch
}

final class BatchComposerImpl: BatchComposer {
    private let stack: Stack
    private let contextHolder: ContextHolder
    
    init(stack: Stack, contextHolder: ContextHolder) {
        self.stack = stack
        self.contextHolder = contextHolder
    }
    
    func makeBatch(of events: [BatchEvent]) -> Batch {
        let common = stack.batchCommon.init(
            instanceId: .init(), // TODO
            batchId: .init(), // TODO
            countryCode: "",
            locale: .current,
            utcOffset: 0
        )
        
        let batch = stack.batch.init(
            common: common,
            context: contextHolder.context,
            events: events
        )
        
        return batch
    }
}
