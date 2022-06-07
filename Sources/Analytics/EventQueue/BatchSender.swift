//
//  BatchSender.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 02/06/2022.
//

import Foundation
import CoreData

enum BatchSendError: Error {
    case serializationError(Error)
    case networkError(URLError)
}

protocol BatchSender {
    func sendBatch(_ batch: Batch, completion: @escaping (Result<Void, BatchSendError>) -> Void)
}

final class BatchSenderImpl: BatchSender {
    func sendBatch(_ batch: Batch, completion: @escaping (Result<Void, BatchSendError>) -> Void) {
        let data: Data
        
        do {
            data = try batch.serialize()
        } catch {
            completion(.failure(.serializationError(error)))
        }
        
        completion(.success(()))
    }
}
