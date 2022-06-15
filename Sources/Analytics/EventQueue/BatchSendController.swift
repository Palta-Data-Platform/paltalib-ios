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
    private let batchSender: BatchSender
    private let stack: Stack
    
    init(batchSender: BatchSender, stack: Stack) {
        self.batchSender = batchSender
        self.stack = stack
    }
    
    func sendBatch(of events: [BatchEvent]) {
        lock.lock()
        defer { lock.unlock() }
        
        guard _isReady else {
            return
        }
    }
}
