//
//  BatchStorage.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

protocol BatchStorage {
    func loadBatch() throws -> Batch?
    func saveBatch(_ batch: Batch) throws
    func removeBatch() throws
}

final class BatchStorageImpl: BatchStorage {
    func loadBatch() throws -> Batch? {
        print("Load batch")
        return nil
    }
    
    func saveBatch(_ batch: Batch) throws {
        print("Save batch")
    }
    
    func removeBatch() throws {
        print("Remove batch")
    }
}
