//
//  EventQueueCoreTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 01.04.2022.
//

import Foundation
import XCTest

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

        queue.sendHandler = { [unowned self] events, completionHandler in
            sentEvents = Array(events)
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

        XCTAssertNil(timerMock.passedInterval)

        timerMock.fire()
        wait(for: [sendIsntCalled], timeout: 0.01)

        queue.config = .init(maxBatchSize: 2, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3, maxConcurrentOperations: .max)

        XCTAssertEqual(timerMock.passedInterval, 3)

        timerMock.fire()
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.01)

        XCTAssertEqual(sentEvents?.count, 1)
    }

    func testTimerBasedSend() {
        queue.config = .init(maxBatchSize: 2, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3, maxConcurrentOperations: .max)
        queue.addEvent(.mock())

        XCTAssertEqual(timerMock.passedInterval, 3)

        wait(for: [sendIsntCalled], timeout: 0.01)

        timerMock.fire()
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.01)

        XCTAssertEqual(sentEvents?.count, 1)
    }

    func testTwoSequentalEvents() {
        queue.config = .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3, maxConcurrentOperations: .max)

        queue.addEvent(.mock())
        XCTAssertEqual(timerMock.passedInterval, 3)

        timerMock.passedInterval = nil
        queue.addEvent(.mock())
        XCTAssertNil(timerMock.passedInterval)

        wait(for: [sendIsntCalled], timeout: 0.01)

        timerMock.fire()
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.01)

        XCTAssertEqual(sentEvents?.count, 2)
    }

    func testThresholdSend() {
        queue.config = .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 2, maxEvents: 3, maxConcurrentOperations: .max)

        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())

        wait(for: [sendIsCalled], timeout: 0.01)

        XCTAssertEqual(sentEvents?.count, 2)

        _sendIsCalled = nil
        timerMock.fire()
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.01)
        XCTAssertEqual(sentEvents?.count, 1)
    }

    func testMultibatchSend1() {
        queue.config = .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 5, maxEvents: 30, maxConcurrentOperations: .max)

        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())

        sendIsCalled.expectedFulfillmentCount = 2
        wait(for: [sendIsCalled], timeout: 0.01)

        XCTAssertEqual(sentEvents?.count, 2)
    }

    func testMultibatchSend2() {
        queue.config = .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 6, maxEvents: 30, maxConcurrentOperations: .max)

        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())
        queue.addEvent(.mock())

        sendIsCalled.expectedFulfillmentCount = 2
        wait(for: [sendIsCalled], timeout: 0.01)

        XCTAssertEqual(sentEvents?.count, 3)
    }

    func testBatchAddWithTimer() {
        queue.config = .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 20, maxEvents: 30, maxConcurrentOperations: .max)

        queue.addEvents(
            Array(repeating: .mock(), count: 10)
        )

        XCTAssertEqual(timerMock.passedInterval, 8)

        wait(for: [sendIsntCalled], timeout: 0.01)

        timerMock.passedInterval = nil
        queue.addEvents(
            Array(repeating: .mock(), count: 3)
        )
        XCTAssertNil(timerMock.passedInterval)

        timerMock.fire()
        wait(for: [sendIsCalled], timeout: 0.01)

        XCTAssertEqual(sentEvents?.count, 13)
    }

    func testBatchAddByCount() {
        queue.config = .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 10, maxEvents: 30, maxConcurrentOperations: .max)

        queue.addEvents(
            Array(repeating: .mock(), count: 9)
        )

        wait(for: [sendIsntCalled], timeout: 0.01)

        queue.addEvents(
            Array(repeating: .mock(), count: 3)
        )

        wait(for: [sendIsCalled], timeout: 0.01)

        XCTAssertEqual(sentEvents?.count, 12)
    }

    func testBatchAddWithOverflow() {
        queue.config = .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 10, maxEvents: 5, maxConcurrentOperations: .max)

        queue.addEvents(
            (0...9).map { Event.mock(timestamp: $0) }
        )

        wait(for: [removeIsCalled], timeout: 0.01)

        let removedTimestamps = Set(removedEvents?.map { $0.timestamp } ?? [])
        let expectedRemovedTimestamps = Set(0...4)

        XCTAssertEqual(removedTimestamps, expectedRemovedTimestamps)
    }

    func testLongUploadByCount() {
        queue.config = .init(maxBatchSize: 2, uploadInterval: 8, uploadThreshold: 2, maxEvents: 30, maxConcurrentOperations: 2)

        sendIsCalled.expectedFulfillmentCount = 2

        queue.addEvents(
            Array(repeating: .mock(), count: 6)
        )

        wait(for: [sendIsCalled], timeout: 0.01)
        wait(for: [sendIsntCalled], timeout: 0.01)

        _sendIsCalled = nil
        _sendIsntCalled = nil

        XCTAssertEqual(completionHandlers.count, 2)
        completionHandlers.forEach { $0() }

        wait(for: [sendIsCalled], timeout: 0.01)
    }

    func testLongUploadWithTimer() {
        queue.config = .init(maxBatchSize: 2, uploadInterval: 8, uploadThreshold: 2, maxEvents: 30, maxConcurrentOperations: 2)

        sendIsCalled.expectedFulfillmentCount = 2

        queue.addEvents(
            Array(repeating: .mock(), count: 5)
        )

        wait(for: [sendIsCalled], timeout: 0.01)
        wait(for: [sendIsntCalled], timeout: 0.01)

        timerMock.fire()

        _sendIsCalled = nil
        _sendIsntCalled = nil

        XCTAssertEqual(completionHandlers.count, 2)
        completionHandlers.forEach { $0() }

        wait(for: [sendIsCalled], timeout: 0.01)
    }
}
