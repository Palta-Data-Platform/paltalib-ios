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
