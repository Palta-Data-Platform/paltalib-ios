//
//  BatchMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel
import PaltaLibAnalytics

struct BatchMock: Batch, Equatable {
    let common: BatchCommonMock?
    let context: BatchContextMock?
    let events: [BatchEventMock]?
    
    let batchId: UUID
    let shouldFailSerialize: Bool
    let data: Data
    
    init(shouldFailSerialize: Bool = false) {
        let batchId = UUID()
        self.batchId = batchId
        self.common = nil
        self.context = nil
        self.events = nil
        
        self.shouldFailSerialize = shouldFailSerialize
        self.data = batchId.data
    }
    
    init(common: BatchCommon, context: BatchContext, events: [BatchEvent]) {
        self.batchId = (common as? BatchCommonMock)?.batchId ?? UUID()
        self.common = common as? BatchCommonMock
        self.context = context as? BatchContextMock
        self.events = events as? [BatchEventMock]
        
        self.shouldFailSerialize = false
        self.data = Data()
    }
    
    init(data: Data) throws {
        self.batchId = UUID(data: data) ?? UUID()
        self.common = nil
        self.context = nil
        self.events = nil
        
        self.shouldFailSerialize = false
        self.data = data
    }
    
    func serialize() throws -> Data {
        if shouldFailSerialize {
            throw NSError(domain: "", code: 0)
        } else {
            return data
        }
    }
}
