//
//  EventQueueCore2Tests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class EventQueueCore2Tests: XCTestCase {
    private var timerMock: TimerMock!
    private var queue: EventQueueCore2Impl!

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
        queue = EventQueueCore2Impl(timer: timerMock)
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

        XCTAssertNil(timerMock.passedInterval)

        timerMock.fire()
        wait(for: [sendIsntCalled], timeout: 0.1)

        queue.config = .init(maxBatchSize: 2, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3)

        XCTAssertEqual(timerMock.passedInterval, 3)

        timerMock.fire()
        wait(for: [sendIsCalled, removeIsntCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 1)
    }

    func testTimerBasedSend() {
        warmUpExpectations(sendIsCalled, removeIsntCalled)
        queue.config = .init(maxBatchSize: 2, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3)
        queue.addEvent(.mock())

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
        
        queue.config = .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 3, maxEvents: 3)

        queue.addEvent(.mock(contextId: contextId))
        XCTAssertEqual(timerMock.passedInterval, 3)

        timerMock.passedInterval = nil
        queue.addEvent(.mock(contextId: contextId))
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
        
        queue.config = .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 2, maxEvents: 3)

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
        
        queue.config = .init(maxBatchSize: 3, uploadInterval: 3, uploadThreshold: 5, maxEvents: 30)

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
        queue.config = .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 20, maxEvents: 30)

        queue.addEvents(
            Array(repeating: .mock(contextId: contextId), count: 10)
        )

        XCTAssertEqual(timerMock.passedInterval, 8)

        wait(for: [sendIsntCalled], timeout: 0.1)

        timerMock.passedInterval = nil
        queue.addEvents(
            Array(repeating: .mock(contextId: contextId), count: 3)
        )
        XCTAssertNil(timerMock.passedInterval)

        timerMock.fire()
        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 13)
    }

    func testBatchAddByCount() {
        warmUpExpectations(sendIsCalled)
        let contextId = UUID()
        queue.config = .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 10, maxEvents: 30)

        queue.addEvents(
            Array(repeating: .mock(contextId: contextId), count: 9)
        )

        wait(for: [sendIsntCalled], timeout: 0.1)

        queue.addEvents(
            Array(repeating: .mock(contextId: contextId), count: 3)
        )

        wait(for: [sendIsCalled], timeout: 0.1)

        XCTAssertEqual(sentEvents?.count, 12)
    }

    func testBatchAddWithOverflow() {
        let contextId = UUID()
        queue.config = .init(maxBatchSize: 300, uploadInterval: 8, uploadThreshold: 10, maxEvents: 5)

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
        
        queue.config = .init(maxBatchSize: 100, uploadInterval: 100, uploadThreshold: 2, maxEvents: 100)
        
        queue.addEvents(events)
        
        wait(for: [sendIsCalled], timeout: 0.1)
        
        XCTAssertEqual(contextId, contextId1)
        XCTAssertEqual(
            sentEvents as? [BatchEventMock],
            events[0...2].map { $0.event.event } as? [BatchEventMock]
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
        
        queue.config = .init(maxBatchSize: 2, uploadInterval: 100, uploadThreshold: 2, maxEvents: 100)
        
        queue.addEvents(events)
        
        wait(for: [sendIsCalled], timeout: 0.1)
        
        XCTAssertEqual(contextId, contextId1)
        XCTAssertEqual(
            sentEvents as? [BatchEventMock],
            events[0...1].map { $0.event.event } as? [BatchEventMock]
        )
    }
    
    func testFlushOnDemandWithTimer() {
        let contextId = UUID()
        queue.config = .init(maxBatchSize: 100, uploadInterval: 1, uploadThreshold: 100, maxEvents: 100)
        
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
        queue.config = .init(maxBatchSize: 100, uploadInterval: 1, uploadThreshold: 3, maxEvents: 100)
        
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
        queue.config = .init(maxBatchSize: 100, uploadInterval: 100, uploadThreshold: 300, maxEvents: 100)
        
        warmUpExpectations(sendIsntCalled)
        
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        queue.addEvent(.mock(contextId: contextId))
        
        queue.sendEventsAvailable()
        
        wait(for: [sendIsntCalled], timeout: 0.1)
    }
    
    private func warmUpExpectations(_ expectations: XCTestExpectation...) {
        // Do nothing. Lazy properties are initiated by this call
    }
}
