//
//  BatchStorageMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class BatchStorageMock: BatchStorage2 {
    var batchToLoad: Batch?
    var batchLoadError: Error?
    var savedBatch: Batch?
    var eventIds: Set<UUID> = []
    var batchRemoved = false
    
    func loadBatch() throws -> Batch? {
        if let batchLoadError = batchLoadError {
            throw batchLoadError
        } else {
            return batchToLoad
        }
    }
    
    func saveBatch<IDS: Collection>(_ batch: Batch, with eventIds: IDS) throws where IDS.Element == UUID {
        savedBatch = batch
        self.eventIds = Set(eventIds)
    }
    
    func saveBatch(_ batch: Batch) throws {
        savedBatch = batch
    }
    
    func removeBatch() throws {
        batchRemoved = true
    }
}
