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
    func makeBatch(of events: [BatchEvent], with contextId: UUID) -> Batch
}

final class BatchComposerImpl: BatchComposer {
    private let stack: Stack
    private let contextProvider: ContextProvider
    
    init(stack: Stack, contextProvider: ContextProvider) {
        self.stack = stack
        self.contextProvider = contextProvider
    }
    
    func makeBatch(of events: [BatchEvent], with contextId: UUID) -> Batch {
        let common = stack.batchCommon.init(
            instanceId: .init(), // TODO
            batchId: .init(), // TODO
            countryCode: "",
            locale: .current,
            utcOffset: 0
        )
        
        let batch = stack.batch.init(
            common: common,
            context: contextProvider.context(with: contextId),
            events: events
        )
        
        return batch
    }
}
