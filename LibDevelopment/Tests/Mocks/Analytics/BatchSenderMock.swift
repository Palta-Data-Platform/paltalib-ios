//
//  BatchSenderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class BatchSenderMock: BatchSender {
    var batch: Batch?
    var result: Result<(), BatchSendError>?
    
    func sendBatch(_ batch: Batch, completion: @escaping (Result<(), BatchSendError>) -> Void) {
        self.batch = batch
        
        if let result = result {
            completion(result)
        }
    }
}
