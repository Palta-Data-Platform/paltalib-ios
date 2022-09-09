//
//  BatchStorage.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel

protocol BatchStorage {
    func loadBatch() throws -> Batch?
    func saveBatch(_ batch: Batch) throws
    func removeBatch() throws
}

final class BatchStorageImpl: BatchStorage {
    private var fileURL: URL {
        folderURL.appendingPathComponent("currentBatch")
    }
    
    private let folderURL: URL
    private let stack: Stack
    private let fileManager: FileManager
    
    init(folderURL: URL, stack: Stack, fileManager: FileManager) {
        self.folderURL = folderURL
        self.stack = stack
        self.fileManager = fileManager
    }
    
    func loadBatch() throws -> Batch? {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        return try stack.batch.init(data: data)
    }
    
    func saveBatch(_ batch: Batch) throws {
        try batch.serialize().write(to: fileURL)
    }
    
    func removeBatch() throws {
        do {
            try fileManager.removeItem(at: fileURL)
        } catch CocoaError.Code.fileNoSuchFile {
            print("PaltaLib: Analytics: No batch to delete")
        }
    }
}
