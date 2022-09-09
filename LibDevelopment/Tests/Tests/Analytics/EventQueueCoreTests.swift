//
//  EventQueueCoreTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation
import XCTest
import PaltaLibAnalyticsModel
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

    private var sentEvents: [UUID: BatchEvent]?
    private var contextId: UUID?
    private var telemetry: Telemetry?
    private var removedEvents: [StorableEvent]?
    
    private var sendResult = true

    override func setUpWithError() throws {
        try super.setUpWithError()

        timerMock = TimerMock()
        queue = EventQueueCoreImpl(timer: timerMock)
        sentEvents = nil
        removedEvents = nil
        sendResult = true

        _sendIsCalled = nil
        _sendIsntCalled = nil
        _removeIsCalled = nil
        _removeIsntCalled = nil

        queue.sendHandler = { [unowned self] events, contextId, telemetry in
            sentEvents = events
            self.telemetry = telemetry
            self.contextId = contextId
            _sendIsCalled?.fulfill()
            _sendIsntCalled?.fulfill()
            
            return sendResult
        }

        queue.removeHandler = { [unowned self] events in
            removedEvents = Array(events)
            _removeIsCalled?.fulfill()
            _removeIsntCalled?.fulfill()
        }
    }

    func testNoSendWithoutConfig() {
        warmUpExpectations(sendIsCalled, removeIsntCalled)
        queue.addEvent(.mock())
        
        waitForQueue()
        XCTAssertNil(timerMock.passedInterval)

        timerMock.fire()

        wait(for: [sendIsntCalled], timeout: 0.1)

        queue.apply(
            .init(maxBatchSize: 2, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3)
        )
        
        waitForQueue()

        XCTAssertEqual(timerMock.passedInterval, 3)

        timerMock.fire()
        
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 1)
    }

    func testTimerBasedSend() {
        warmUpExpectations(sendIsCalled, removeIsntCalled)
        
        queue.apply(
            .init(maxBatchSize: 2, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3)
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
        let contextId = UUID()
        
        warmUpExpectations(sendIsCalled)
        
        queue.apply(
            .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3)
        )
        
        waitForQueue()

        queue.addEvent(.mock(contextId: contextId))
        XCTAssertEqual(timerMock.passedInterval, 3)

        timerMock.passedInterval = nil
        queue.addEvent(.mock(contextId: contextId))
        
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
        warmUpExpectations(sendIsCalled, removeIsntCalled)
        let contextId = UUID()
        
        queue.apply(
            .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 2, maxEvents: 3)
        )
        
        waitForQueue()

        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))

        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 2)

        _sendIsCalled = nil
        timerMock.fire()
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.1)
        XCTAssertEqual(sentEvents?.count, 1)
    }

    func testMultibatchSend1() {
        let contextId = UUID()
        
        warmUpExpectations(sendIsCalled)
        
        queue.apply(
            .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 5, maxEvents: 30)
        )
        
        waitForQueue()

        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))

        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 3)
        XCTAssertEqual(telemetry?.batchLoad, 1)
        XCTAssertEqual(telemetry?.eventsInBatch, 3)
        XCTAssertEqual(telemetry?.eventsDroppedSinceLastBatch, 0)
    }

    func testBatchAddWithTimer() {
        warmUpExpectations(sendIsCalled)
        let contextId = UUID()
        
        queue.apply(
            .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 20, maxEvents: 30)
        )
        
        waitForQueue()

        queue.addEvents(
            .mock(count: 10, contextId: contextId)
        )
        
        waitForQueue()

        XCTAssertEqual(timerMock.passedInterval, 8)

        wait(for: [sendIsntCalled], timeout: 0.1)

        timerMock.passedInterval = nil
        queue.addEvents(
            .mock(count: 3, contextId: contextId)
        )
        
        waitForQueue()
        XCTAssertNil(timerMock.passedInterval)

        timerMock.fire()
        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 13)
    }

    func testBatchAddByCount() {
        warmUpExpectations(sendIsCalled)
        let contextId = UUID()
        
        queue.apply(
            .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 10, maxEvents: 30)
        )
        
        waitForQueue()

        queue.addEvents(
            .mock(count: 9, contextId: contextId)
        )

        wait(for: [sendIsntCalled], timeout: 0.1)

        queue.addEvents(
            .mock(count: 3, contextId: contextId)
        )

        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 12)
    }

    func testBatchAddWithOverflow() {
        warmUpExpectations(removeIsCalled)
        let contextId = UUID()
        
        queue.apply(
            .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 10, maxEvents: 5)
        )
        
        waitForQueue()

        queue.addEvents(
            (0...9).map { StorableEvent.mock(timestamp: $0, contextId: contextId) }
        )

        wait(for: [removeIsCalled], timeout: 0.1)

        let removedTimestamps = Set(removedEvents?.map { $0.event.event.timestamp } ?? [])
        let expectedRemovedTimestamps = Set(0...4)

        XCTAssertEqual(removedTimestamps, expectedRemovedTimestamps)

        timerMock.fire()

        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(telemetry?.batchLoad, 5 / 300)
        XCTAssertEqual(telemetry?.eventsInBatch, 5)
        XCTAssertEqual(telemetry?.eventsDroppedSinceLastBatch, 5)
    }
    
    func testSendMultipleContexts() {
        warmUpExpectations(sendIsCalled)
        let contextId1 = UUID()
        let contextId2 = UUID()
        let contextId3 = UUID()
        
        let events: [StorableEvent] = [
            .mock(timestamp: 0, contextId: contextId1),
            .mock(timestamp: 1, contextId: contextId1),
            .mock(timestamp: 2, contextId: contextId1),
            .mock(timestamp: 3, contextId: contextId2),
            .mock(timestamp: 4, contextId: contextId2),
            .mock(timestamp: 5, contextId: contextId3)
        ]
        
        queue.apply(
            .init(maxBatchSize: 100, uploadInterval: 100, uploadThreshold: 2, maxEvents: 100)
        )
        waitForQueue()
        
        queue.addEvents(events)
        
        wait(for: [sendIsCalled], timeout: 0.1)
        
        XCTAssertEqual(contextId, contextId1)
        XCTAssertEqual(
            Set(sentEvents?.values.compactMap { $0 as? BatchEventMock } ?? []),
            Set(events[0...2].map { $0.event.event } as? [BatchEventMock] ?? [])
        )
    }
    
    func testSendMultipleContextsOverBatchLimit() {
        let contextId1 = UUID()
        let contextId2 = UUID()
        let contextId3 = UUID()
        
        let events: [StorableEvent] = [
            .mock(timestamp: 0, contextId: contextId1),
            .mock(timestamp: 1, contextId: contextId1),
            .mock(timestamp: 2, contextId: contextId1),
            .mock(timestamp: 3, contextId: contextId2),
            .mock(timestamp: 4, contextId: contextId2),
            .mock(timestamp: 5, contextId: contextId3)
        ]
        
        queue.apply(
            .init(maxBatchSize: 2, uploadInterval: 100, uploadThreshold: 2, maxEvents: 100)
        )
        waitForQueue()
        
        queue.addEvents(events)
        
        wait(for: [sendIsCalled], timeout: 0.1)
        
        XCTAssertEqual(contextId, contextId1)
        XCTAssertEqual(
            Set(sentEvents?.values.compactMap { $0 as? BatchEventMock } ?? []),
            Set(events[0...1].map { $0.event.event } as? [BatchEventMock] ?? [])
        )
    }
    
    func testFlushOnDemandWithTimer() {
        let contextId = UUID()
        queue.apply(
            .init(maxBatchSize: 100, uploadInterval: 1, uploadThreshold: 100, maxEvents: 100)
        )
        waitForQueue()
        
        warmUpExpectations(sendIsCalled)
        
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        
        sendResult = false
        
        timerMock.fire()
        
        wait(for: [sendIsCalled], timeout: 0.1)
        
        _sendIsCalled = nil
        _sendIsntCalled = nil
        warmUpExpectations(sendIsCalled)
        sentEvents = nil
        sendResult = true
        
        queue.sendEventsAvailable()
        
        wait(for: [sendIsCalled], timeout: 0.1)
        
        XCTAssertEqual(sentEvents?.count, 3)
        
        _sendIsCalled = nil
        _sendIsntCalled = nil
        warmUpExpectations(sendIsntCalled)
        queue.sendEventsAvailable()
        wait(for: [sendIsntCalled], timeout: 0.1)
    }
    
    func testFlushOnDemandWithCount() {
        let contextId = UUID()
        queue.apply(
            .init(maxBatchSize: 100, uploadInterval: 1, uploadThreshold: 3, maxEvents: 100)
        )
        waitForQueue()
        
        warmUpExpectations(sendIsCalled)
        
        sendResult = false
        
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        
        wait(for: [sendIsCalled], timeout: 0.1)
        
        _sendIsCalled = nil
        _sendIsntCalled = nil
        warmUpExpectations(sendIsCalled)
        sentEvents = nil
        sendResult = true
        
        queue.sendEventsAvailable()
        
        wait(for: [sendIsCalled], timeout: 0.1)
        
        XCTAssertEqual(sentEvents?.count, 3)
        
        _sendIsCalled = nil
        _sendIsntCalled = nil
        warmUpExpectations(sendIsntCalled)
        queue.sendEventsAvailable()
        wait(for: [sendIsntCalled], timeout: 0.1)
    }
    
    func testFlushOnDemandNoTrigger() {
        let contextId = UUID()
        queue.apply(
            .init(maxBatchSize: 100, uploadInterval: 100, uploadThreshold: 300, maxEvents: 100)
        )
        waitForQueue()
        
        warmUpExpectations(sendIsntCalled)
        
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        
        queue.sendEventsAvailable()
        
        wait(for: [sendIsntCalled], timeout: 0.1)
    }
    
    func testFlushByMultipleContexts() {
        let contextId1 = UUID()
        let contextId2 = UUID()
        let contextId3 = UUID()
        
        let events: [StorableEvent] = [
            .mock(timestamp: 0, contextId: contextId1),
            .mock(timestamp: 1, contextId: contextId1),
            .mock(timestamp: 2, contextId: contextId1),
            .mock(timestamp: 3, contextId: contextId2),
            .mock(timestamp: 4, contextId: contextId2),
            .mock(timestamp: 5, contextId: contextId3)
        ]
        
        queue.apply(
            .init(maxBatchSize: 200, uploadInterval: 100, uploadThreshold: 200, maxEvents: 100)
        )
        waitForQueue()
        
        queue.addEvents(events)
        
        wait(for: [sendIsCalled], timeout: 0.15)
        
        XCTAssertEqual(contextId, contextId1)
        XCTAssertEqual(
            Set(sentEvents?.values.compactMap { $0 as? BatchEventMock } ?? []),
            Set(events[0...2].map { $0.event.event } as? [BatchEventMock] ?? [])
        )
    }
    
    private func warmUpExpectations(_ expectations: XCTestExpectation...) {
        // Do nothing. Lazy properties are initiated by this call
    }
    
    private func waitForQueue(file: StaticString = #file, line: Int = #line) {
        let expectation = self.expectation(description: "Waiting for queue")
        queue.addBarrier(expectation.fulfill)
        wait(for: [expectation], timeout: 0.05)
    }
}
