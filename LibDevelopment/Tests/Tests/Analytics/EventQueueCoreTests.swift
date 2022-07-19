//
//  EventQueueCoreTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 01.04.2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class EventQueueCoreTests: XCTestCase {
    private var timerMock: TimerMock!
    private var queue: EventQueueCoreImpl!

    private var sendIsCalled: XCTestExpectation {
        if let value = _sendIsCalled {
            return value
        } else {
            let value = expectation(description: "Send is called")
            _sendIsCalled = value
            return value
        }
    }

    private var sendIsntCalled: XCTestExpectation {
        if let value = _sendIsntCalled {
            return value
        } else {
            let value = expectation(description: "Send isn't called")
            value.isInverted = true
            _sendIsntCalled = value
            return value
        }
    }

    private var removeIsCalled: XCTestExpectation {
        if let value = _removeIsCalled {
            return value
        } else {
            let value = expectation(description: "Remove is called")
            _removeIsCalled = value
            return value
        }
    }

    private var removeIsntCalled: XCTestExpectation {
        if let value = _removeIsntCalled {
            return value
        } else {
            let value = expectation(description: "Remove isn't called")
            value.isInverted = true
            _removeIsntCalled = value
            return value
        }
    }


    private var _sendIsCalled: XCTestExpectation?
    private var _sendIsntCalled: XCTestExpectation?
    private var _removeIsCalled: XCTestExpectation?
    private var _removeIsntCalled: XCTestExpectation?

    private var completionHandlers: [() -> Void] = []
    private var sentEvents: [Event]?
    private var telemetry: Telemetry?
    private var removedEvents: [Event]?

    override func setUpWithError() throws {
        try super.setUpWithError()

        timerMock = TimerMock()
        queue = EventQueueCoreImpl(timer: timerMock)
        sentEvents = nil
        removedEvents = nil
        completionHandlers = []

        _sendIsCalled = nil
        _sendIsntCalled = nil
        _removeIsCalled = nil
        _removeIsntCalled = nil

        queue.sendHandler = { [unowned self] events, telemetry, completionHandler in
            sentEvents = Array(events)
            self.telemetry = telemetry
            completionHandlers.append(completionHandler)
            _sendIsCalled?.fulfill()
            _sendIsntCalled?.fulfill()
        }

        queue.removeHandler = { [unowned self] events in
            removedEvents = Array(events)
            _removeIsCalled?.fulfill()
            _removeIsntCalled?.fulfill()
        }
    }

    func testNoSendWithoutConfig() {
        queue.addEvent(.mock())
        
        waitForQueue()
        XCTAssertNil(timerMock.passedInterval)

        timerMock.fire()

        wait(for: [sendIsntCalled], timeout: 0.1)

        queue.apply(
            .init(maxBatchSize: 2, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3, maxConcurrentOperations: .max)
        )
        
        waitForQueue()

        XCTAssertEqual(timerMock.passedInterval, 3)

        timerMock.fire()
        
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 1)
    }

    func testTimerBasedSend() {
        queue.apply(
            .init(maxBatchSize: 2, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3, maxConcurrentOperations: .max)
        )
        
        waitForQueue()
        
        queue.addEvent(.mock())
        waitForQueue()

        XCTAssertEqual(timerMock.passedInterval, 3)

        wait(for: [sendIsntCalled], timeout: 0.1)

        timerMock.fire()
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 1)
        XCTAssertEqual(telemetry?.batchLoad, 1 / 2)
        XCTAssertEqual(telemetry?.eventsInBatch, 1)
        XCTAssertEqual(telemetry?.eventsDroppedSinceLastBatch, 0)
    }

    func testTwoSequentalEvents() {
        queue.apply(
            .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3, maxConcurrentOperations: .max)
        )
        
        waitForQueue()

        queue.addEvent(.mock())
        waitForQueue()
        XCTAssertEqual(timerMock.passedInterval, 3)

        timerMock.passedInterval = nil
        queue.addEvent(.mock())
        waitForQueue()
        XCTAssertNil(timerMock.passedInterval)

        wait(for: [sendIsntCalled], timeout: 0.1)

        timerMock.fire()
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 2)
        XCTAssertEqual(telemetry?.batchLoad, 2 / 3)
        XCTAssertEqual(telemetry?.eventsInBatch, 2)
        XCTAssertEqual(telemetry?.eventsDroppedSinceLastBatch, 0)
    }

    func testThresholdSend() {
        queue.apply(
            .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 2, maxEvents: 3, maxConcurrentOperations: .max)
        )
        
        waitForQueue()

        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())

        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 2)

        _sendIsCalled = nil
        timerMock.fire()
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.1)
        XCTAssertEqual(sentEvents?.count, 1)
    }

    func testMultibatchSend1() {
        queue.apply(
            .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 5, maxEvents: 30, maxConcurrentOperations: .max)
        )
        
        waitForQueue()

        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())

        sendIsCalled.expectedFulfillmentCount = 2
        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 2)
        XCTAssertEqual(telemetry?.batchLoad, 2 / 3)
        XCTAssertEqual(telemetry?.eventsInBatch, 2)
        XCTAssertEqual(telemetry?.eventsDroppedSinceLastBatch, 0)
    }

    func testMultibatchSend2() {
        queue.apply(
            .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 6, maxEvents: 30, maxConcurrentOperations: .max)
        )
        
        waitForQueue()

        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())

        sendIsCalled.expectedFulfillmentCount = 2
        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 3)
    }

    func testBatchAddWithTimer() {
        queue.apply(
            .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 20, maxEvents: 30, maxConcurrentOperations: .max)
        )
        
        waitForQueue()

        queue.addEvents(
            Array(repeating: .mock(), count: 10)
        )
        
        waitForQueue()

        XCTAssertEqual(timerMock.passedInterval, 8)

        wait(for: [sendIsntCalled], timeout: 0.1)

        timerMock.passedInterval = nil
        queue.addEvents(
            Array(repeating: .mock(), count: 3)
        )
        
        waitForQueue()
        XCTAssertNil(timerMock.passedInterval)

        timerMock.fire()
        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 13)
    }

    func testBatchAddByCount() {
        queue.apply(
            .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 10, maxEvents: 30, maxConcurrentOperations: .max)
        )
        
        waitForQueue()

        queue.addEvents(
            Array(repeating: .mock(), count: 9)
        )

        wait(for: [sendIsntCalled], timeout: 0.1)

        queue.addEvents(
            Array(repeating: .mock(), count: 3)
        )

        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 12)
    }

    func testBatchAddWithOverflow() {
        queue.apply(
            .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 10, maxEvents: 5, maxConcurrentOperations: .max)
        )
        
        waitForQueue()

        queue.addEvents(
            (0...9).map { Event.mock(timestamp: $0) }
        )

        wait(for: [removeIsCalled], timeout: 0.1)

        let removedTimestamps = Set(removedEvents?.map { $0.timestamp } ?? [])
        let expectedRemovedTimestamps = Set(0...4)

        XCTAssertEqual(removedTimestamps, expectedRemovedTimestamps)

        timerMock.fire()

        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(telemetry?.batchLoad, 5 / 300)
        XCTAssertEqual(telemetry?.eventsInBatch, 5)
        XCTAssertEqual(telemetry?.eventsDroppedSinceLastBatch, 5)
    }

    func testLongUploadByCount() {
        queue.apply(
            .init(maxBatchSize: 2, uploadInterval: 8, uploadThreshold: 2, maxEvents: 30, maxConcurrentOperations: 2)
        )
        
        waitForQueue()

        sendIsCalled.expectedFulfillmentCount = 2

        queue.addEvents(
            Array(repeating: .mock(), count: 6)
        )

        wait(for: [sendIsCalled], timeout: 0.1)
        wait(for: [sendIsntCalled], timeout: 0.1)

        _sendIsCalled = nil
        _sendIsntCalled = nil

        XCTAssertEqual(completionHandlers.count, 2)
        completionHandlers.forEach { $0() }

        wait(for: [sendIsCalled], timeout: 0.1)
    }

    func testLongUploadWithTimer() {
        queue.apply(
            .init(maxBatchSize: 2, uploadInterval: 8, uploadThreshold: 2, maxEvents: 30, maxConcurrentOperations: 2)
        )
        
        waitForQueue()

        sendIsCalled.expectedFulfillmentCount = 2

        queue.addEvents(
            Array(repeating: .mock(), count: 5)
        )

        wait(for: [sendIsCalled], timeout: 0.1)
        wait(for: [sendIsntCalled], timeout: 0.1)

        timerMock.fire()

        _sendIsCalled = nil
        _sendIsntCalled = nil

        XCTAssertEqual(completionHandlers.count, 2)
        completionHandlers.forEach { $0() }

        wait(for: [sendIsCalled], timeout: 0.1)
    }
    
    private func waitForQueue(file: StaticString = #file, line: Int = #line) {
        let expectation = self.expectation(description: "Waiting for queue")
        queue.addBarrier(expectation.fulfill)
        wait(for: [expectation], timeout: 0.05)
    }
}
