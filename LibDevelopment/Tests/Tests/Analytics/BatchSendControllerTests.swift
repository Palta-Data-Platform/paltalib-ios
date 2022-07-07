//
//  BatchSendControllerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class BatchSendControllerTests: XCTestCase {
    private var composerMock: BatchComposerMock!
    private var storageMock: BatchStorageMock!
    private var senderMock: BatchSenderMock!
    private var eventStorageMock: EventStorageMock!
    private var timerMock: TimerMock!
    
    private var controller: BatchSendControllerImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        composerMock = .init()
        storageMock = .init()
        senderMock = .init()
        eventStorageMock = .init()
        timerMock = .init()
        
        controller = BatchSendControllerImpl(
            batchComposer: composerMock,
            batchStorage: storageMock,
            batchSender: senderMock,
            eventStorage: eventStorageMock,
            timer: timerMock
        )
    }
    
    func testSuccessfulSend() {
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        
        let contextId = UUID()
        let events = Dictionary(
            grouping: (0...10).map { _ in BatchEventMock() },
            by: { _ in UUID() }
        )
            .compactMapValues { $0.first }
        
        senderMock.result = .success(())
        
        controller.sendBatch(of: events, with: contextId)
        
        wait(for: [isReadyCalled], timeout: 0.1)
        
        XCTAssertEqual(Set(composerMock.events as? [BatchEventMock] ?? []), Set(events.values))
        XCTAssertEqual(composerMock.contextId, contextId)
        XCTAssertNotNil(senderMock.batch as? BatchMock)
        XCTAssertNotNil(storageMock.savedBatch)
        XCTAssert(storageMock.batchRemoved)
        XCTAssertEqual(eventStorageMock.removedIds.count, 11)
        XCTAssert(controller.isReady)
    }
    
    func testSequentalSend() {
        let isReadyNotCalled = expectation(description: "Is Ready called")
        isReadyNotCalled.isInverted = true
        controller.isReadyCallback = isReadyNotCalled.fulfill
        
        let contextId = UUID()
        let events1 = [UUID(): BatchEventMock()]
        let events2 = [UUID(): BatchEventMock()]
        
        controller.sendBatch(of: events1, with: contextId)
        
        composerMock.events = nil
        composerMock.contextId = nil
        senderMock.batch = nil
        storageMock.savedBatch = nil
        eventStorageMock.removedIds = []
        
        controller.sendBatch(of: events2, with: contextId)
        
        wait(for: [isReadyNotCalled], timeout: 0.1)
        
        XCTAssertNil(composerMock.events)
        XCTAssertNil(senderMock.batch)
        XCTAssertNil(storageMock.savedBatch)
        XCTAssert(eventStorageMock.removedIds.isEmpty)
        XCTAssertFalse(controller.isReady)
    }
    
    func testUnknownError() {
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        
        senderMock.result = .failure(.unknown)
        
        controller.sendBatch(of: events, with: contextId)
        
        wait(for: [isReadyCalled], timeout: 0.1)

        XCTAssertNotNil(storageMock.savedBatch)
        XCTAssert(storageMock.batchRemoved)
        XCTAssert(controller.isReady)
    }
    
    func testSerializationError() {
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        
        senderMock.result = .failure(.serializationError(NSError(domain: "", code: 0)))
        
        controller.sendBatch(of: events, with: contextId)
        
        wait(for: [isReadyCalled], timeout: 0.1)

        XCTAssertNotNil(storageMock.savedBatch)
        XCTAssert(storageMock.batchRemoved)
        XCTAssert(controller.isReady)
    }
    
    func testServerError() {
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        
        senderMock.result = .failure(.serverError)
        
        controller.sendBatch(of: events, with: contextId)
        
        XCTAssertNotNil(timerMock.passedInterval)
        XCTAssertFalse(storageMock.batchRemoved)
        XCTAssertFalse(controller.isReady)
        
        senderMock.result = .success(())
        timerMock.fire()
        
        wait(for: [isReadyCalled], timeout: 0.1)

        XCTAssertNotNil(storageMock.savedBatch)
        XCTAssert(storageMock.batchRemoved)
        XCTAssert(controller.isReady)
    }
    
    func testNoInternet() {
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        
        senderMock.result = .failure(.noInternet)
        
        controller.sendBatch(of: events, with: contextId)
        
        XCTAssertNotNil(timerMock.passedInterval)
        XCTAssertFalse(storageMock.batchRemoved)
        XCTAssertFalse(controller.isReady)
        
        senderMock.result = .success(())
        timerMock.fire()
        
        wait(for: [isReadyCalled], timeout: 0.1)

        XCTAssertNotNil(storageMock.savedBatch)
        XCTAssert(storageMock.batchRemoved)
        XCTAssert(controller.isReady)
    }
    
    func testTimeoutError() {
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        
        senderMock.result = .failure(.timeout)
        
        controller.sendBatch(of: events, with: contextId)
        
        XCTAssertNotNil(timerMock.passedInterval)
        XCTAssertFalse(storageMock.batchRemoved)
        XCTAssertFalse(controller.isReady)
        
        senderMock.result = .success(())
        timerMock.fire()
        
        wait(for: [isReadyCalled], timeout: 0.1)

        XCTAssertNotNil(storageMock.savedBatch)
        XCTAssert(storageMock.batchRemoved)
        XCTAssert(controller.isReady)
    }
    
    func testURLError() {
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        
        senderMock.result = .failure(.networkError(URLError(.cannotConnectToHost)))
        
        controller.sendBatch(of: events, with: contextId)
        
        XCTAssertNotNil(timerMock.passedInterval)
        XCTAssertFalse(storageMock.batchRemoved)
        XCTAssertFalse(controller.isReady)
        
        senderMock.result = .success(())
        timerMock.fire()
        
        wait(for: [isReadyCalled], timeout: 0.1)

        XCTAssertNotNil(storageMock.savedBatch)
        XCTAssert(storageMock.batchRemoved)
        XCTAssert(controller.isReady)
    }
    
    func testNotConfiguredError() {
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        
        senderMock.result = .failure(.notConfigured)
        
        controller.sendBatch(of: events, with: contextId)
        
        XCTAssertNotNil(timerMock.passedInterval)
        XCTAssertFalse(storageMock.batchRemoved)
        XCTAssertFalse(controller.isReady)
        
        senderMock.result = .success(())
        timerMock.fire()
        
        wait(for: [isReadyCalled], timeout: 0.1)

        XCTAssertNotNil(storageMock.savedBatch)
        XCTAssert(storageMock.batchRemoved)
        XCTAssert(controller.isReady)
    }
    
    func testMaxRetry() {
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        
        var retryCount = 0
        
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        
        senderMock.result = .failure(.notConfigured)
        
        controller.sendBatch(of: events, with: contextId)
        
        repeat {
            timerMock.passedInterval = nil
            timerMock.fireAndWait()
            retryCount += 1
            
            if retryCount > 10 {
                XCTAssert(false)
            }
        } while timerMock.passedInterval != nil
        
        XCTAssertEqual(retryCount, 10)
        
        wait(for: [isReadyCalled], timeout: 0.1)
        
        XCTAssert(storageMock.batchRemoved)
        XCTAssert(controller.isReady)
    }
    
    func testSendOldBatch() {
        storageMock.batchToLoad = BatchMock()
        senderMock.result = .failure(.noInternet)
        
        controller = BatchSendControllerImpl(
            batchComposer: composerMock,
            batchStorage: storageMock,
            batchSender: senderMock,
            eventStorage: eventStorageMock,
            timer: timerMock
        )
        
        XCTAssertFalse(controller.isReady)
        XCTAssertNil(composerMock.events)
        XCTAssertNil(composerMock.contextId)
        XCTAssertNotNil(senderMock.batch as? BatchMock)
        XCTAssert(eventStorageMock.removedIds.isEmpty)
        
        senderMock.result = .success(())
        let isReadyCalled = expectation(description: "Is Ready called")
        controller.isReadyCallback = isReadyCalled.fulfill
        timerMock.fire()
        
        wait(for: [isReadyCalled], timeout: 0.1)
        
        XCTAssert(storageMock.batchRemoved)
        XCTAssert(controller.isReady)
    }
}
