//
//  BatchStorageMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class BatchStorageMock: BatchStorage {
    var batchToLoad: Batch?
    var batchLoadError: Error?
    var savedBatch: Batch?
    var batchRemoved = false
    
    func loadBatch() throws -> Batch? {
        if let batchLoadError = batchLoadError {
            throw batchLoadError
        } else {
            return batchToLoad
        }
    }
    
    func saveBatch(_ batch: Batch) throws {
        savedBatch = batch
    }
    
    func removeBatch() throws {
        batchRemoved = true
    }
}
