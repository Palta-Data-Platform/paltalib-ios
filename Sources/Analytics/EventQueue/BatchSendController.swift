//
//  BatchSendController.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation

protocol BatchSendController {
    var isReady: Bool { get }
    var isReadyCallback: (() -> Void)? { get set }
    
    func sendBatch(of events: [BatchEvent])
}

final class BatchSendControllerImpl: BatchSendController {
    var isReady: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isReady
    }
    
    var isReadyCallback: (() -> Void)?
    
    private var _isReady = true {
        didSet {
            if _isReady {
                isReadyCallback?()
            }
        }
    }
    
    private let lock = NSRecursiveLock()
    private let batchComposer: BatchComposer
    private let batchStorage: BatchStorage
    private let batchSender: BatchSender
    private let eventStorage: EventStorage2
    
    init(
        batchComposer: BatchComposer,
        batchStorage: BatchStorage,
        batchSender: BatchSender,
        eventStorage: EventStorage2
    ) {
        self.batchComposer = batchComposer
        self.batchStorage = batchStorage
        self.batchSender = batchSender
        self.eventStorage = eventStorage
    }
    
    func sendBatch(of events: [BatchEvent]) {
        lock.lock()
        defer { lock.unlock() }
        
        guard _isReady else {
            return
        }
        
        let batch = batchComposer.makeBatch(of: events)
        try! batchStorage.saveBatch(batch)
        
        batchSender.sendBatch(batch) { [weak self] result in
            switch result {
            case .success:
                self?.completeBatchSend()
                
            case .failure:
                break
            }
        }
    }
    
    private func completeBatchSend() {
        lock.lock()
        try! batchStorage.removeBatch()
        _isReady = true
        lock.unlock()
    }
}
