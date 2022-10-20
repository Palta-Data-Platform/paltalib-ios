//
//  BatchStorage.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

import Foundation
import PaltaLibCore

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
    private let fileManager: FileManager
    
    private let decoder = JSONDecoder()
    
    private let encoder: JSONEncoder = JSONEncoder().do {
        $0.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.description)
        }
    }
    
    init(folderURL: URL, fileManager: FileManager) {
        self.folderURL = folderURL
        self.fileManager = fileManager
    }
    
    func loadBatch() throws -> Batch? {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(Batch.self, from: data)
    }
    
    func saveBatch(_ batch: Batch) throws {
        try encoder.encode(batch).write(to: fileURL)
    }
    
    func removeBatch() throws {
        do {
            try fileManager.removeItem(at: fileURL)
        } catch CocoaError.Code.fileNoSuchFile {
            print("PaltaLib: Analytics: No batch to delete")
        }
    }
}
