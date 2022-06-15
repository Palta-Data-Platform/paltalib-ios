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
        
        let batch = stack.batch.init(common: common, context: contextHolder.context, events: events)
        
        return batch
    }
}
