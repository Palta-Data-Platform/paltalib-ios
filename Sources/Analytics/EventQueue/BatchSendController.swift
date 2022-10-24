//
//  BatchSendController.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

import Foundation

protocol BatchSendController: AnyObject {
    var isReady: Bool { get }
    var isReadyCallback: (() -> Void)? { get set }
    
    func sendBatch(of events: [Event], with telemetry: Telemetry)
}

final class BatchSendControllerImpl: BatchSendController {
    var isReady: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isReady
    }
    
    var isReadyCallback: (() -> Void)?
    
    private var _isReady = false {
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
    private let eventStorage: EventStorage
    private let timer: Timer
    
    init(
        batchComposer: BatchComposer,
        batchStorage: BatchStorage,
        batchSender: BatchSender,
        eventStorage: EventStorage,
        timer: Timer
    ) {
        self.batchComposer = batchComposer
        self.batchStorage = batchStorage
        self.batchSender = batchSender
        self.eventStorage = eventStorage
        self.timer = timer
    }
    
    func sendBatch(of events: [Event], with telemetry: Telemetry) {
        lock.lock()
        defer { lock.unlock() }
        
        guard _isReady else {
            return
        }
        
        _isReady = false
        
        let batch = batchComposer.makeBatch(of: events, telemetry: telemetry)
        
        do {
            try batchStorage.saveBatch(batch)
            events.forEach {
                eventStorage.removeEvent($0)
            }
        } catch {
            print("PaltaLib: Analytics: Error saving batch: \(error)")
            completeBatchSend()
            return
        }
        
        send(batch)
    }
    
    func configurationFinished() {
        checkForUnsentBatch()
    }
    
    private func completeBatchSend() {
        lock.lock()
        try! batchStorage.removeBatch()
        _isReady = true
        lock.unlock()
    }
    
    private func handle(_ error: BatchSendError, for batch: Batch, retryCount: Int) {
        switch error {
        case .notConfigured:
            print("PaltaLib: Analytics: Batch send failed due to SDK misconfiguration")
            scheduleBatchSend(batch, retryCount: retryCount + 1)
            
        case .serializationError:
            print("PaltaLib: Analytics: Batch send failed due to serialization error")
            completeBatchSend()
            
        case .networkError,.serverError, .noInternet, .timeout:
            scheduleBatchSend(batch, retryCount: retryCount + 1)
            
        case .unknown:
            print("PaltaLib: Analytics: Batch send failed due to unknown error")
            completeBatchSend()
        }
    }
    
    private func send(_ batch: Batch, retryCount: Int = 0) {
        batchSender.sendBatch(batch) { [weak self] result in
            switch result {
            case .success:
                self?.completeBatchSend()
                
            case .failure(let error):
                self?.handle(error, for: batch, retryCount: retryCount)
            }
        }
    }
    
    private func scheduleBatchSend(_ batch: Batch, retryCount: Int) {
        guard retryCount <= 10 else {
            completeBatchSend()
            return
        }
        
        let interval = min(0.25 * pow(2, TimeInterval(retryCount)), 5 * 60)
        
        timer.scheduleTimer(timeInterval: interval, on: .global(qos: .background)) { [weak self] in
            self?.send(batch, retryCount: retryCount)
        }
    }
    
    private func checkForUnsentBatch() {
        do {
            guard let batch = try batchStorage.loadBatch() else {
                _isReady = true
                return
            }
            
            _isReady = false
            send(batch)
        } catch {
            print("PaltaLib: Analytics: Error retrieving batch from storage")
        }
    }
}
