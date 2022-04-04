//
//  EventQueueTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import XCTest

final class EventQueueTests: XCTestCase {
    var eventQueue: EventQueue!
    var coreMock: EventQueueCoreMock!
    var timerMock: TimerMock!
    var storageMock: EventStorageMock!
    var senderMock: EventSenderMock!
    var composerMock: EventComposerMock!

    override func setUpWithError() throws {
        try super.setUpWithError()

        coreMock = .init()
        timerMock = .init()
        storageMock = .init()
        senderMock = .init()
        composerMock = .init()

        eventQueue = .init(
            core: coreMock,
            storage: storageMock,
            sender: senderMock,
            eventComposer: composerMock,
            timer: timerMock
        )
    }

    func testAddEvent() {
        eventQueue.logEvent(
            eventType: "event-type",
            eventProperties: ["prop": "1"],
            groups: ["group": 2],
            timestamp: 22
        )

        XCTAssertEqual(composerMock.eventType, "event-type")
        XCTAssertEqual(composerMock.eventProperties as? [String: String], ["prop": "1"])
        XCTAssertEqual(composerMock.groups as? [String: Int], ["group": 2])
        XCTAssertEqual(composerMock.timestamp, 22)

        XCTAssertEqual(coreMock.addedEvents, [.mock()])
        XCTAssertEqual(storageMock.addedEvents, [.mock()])
        XCTAssertNil(senderMock.sentEvents)
        XCTAssertNil(timerMock.passedInterval)
    }

    func testInit() {
        storageMock.eventsToLoad = Array(repeating: .mock(), count: 30)

        eventQueue = .init(
            core: coreMock,
            storage: storageMock,
            sender: senderMock,
            eventComposer: composerMock,
            timer: timerMock
        )

        XCTAssertEqual(storageMock.eventsToLoad, coreMock.addedEvents)
        XCTAssertNotNil(coreMock.sendHandler)
        XCTAssertNotNil(coreMock.removeHandler)
    }

    func testSuccessfulSend() {
        let sendCompleted = expectation(description: "Send completed")
        let eventsToSend = (0...100).map { Event.mock(timestamp: $0) }
        senderMock.result = .success(())

        coreMock.sendHandler?(ArraySlice(eventsToSend), sendCompleted.fulfill)

        XCTAssertEqual(senderMock.sentEvents, eventsToSend)
        wait(for: [sendCompleted], timeout: 0.01)
        XCTAssertEqual(storageMock.removedEvents, eventsToSend)
    }

    func testSendNoError() {
        let sendCompleted = expectation(description: "Send completed")
        let sendIsntCompleted = expectation(description: "Send isn't completed")
        sendIsntCompleted.isInverted = true

        let completion = {
            sendCompleted.fulfill()
            sendIsntCompleted.fulfill()
        }

        let eventsToSend = (0...100).map { Event.mock(timestamp: $0) }
        senderMock.result = .failure(.noInternet)

        coreMock.sendHandler?(ArraySlice(eventsToSend), completion)

        wait(for: [sendIsntCompleted], timeout: 0.03)

        XCTAssertEqual(senderMock.sentEvents, eventsToSend)
        XCTAssert(storageMock.removedEvents.isEmpty)
        XCTAssertEqual(coreMock.addedEvents, eventsToSend)

        timerMock.fire()
        wait(for: [sendCompleted], timeout: 0.01)
        XCTAssert(storageMock.removedEvents.isEmpty)
    }

    func testSendClientError() {
        let sendCompleted = expectation(description: "Send completed")

        let eventsToSend = (0...100).map { Event.mock(timestamp: $0) }
        senderMock.result = .failure(.badRequest)

        coreMock.sendHandler?(ArraySlice(eventsToSend), sendCompleted.fulfill)

        wait(for: [sendCompleted], timeout: 0.03)

        XCTAssertEqual(senderMock.sentEvents, eventsToSend)
        XCTAssert(coreMock.addedEvents.isEmpty)
        XCTAssertEqual(storageMock.removedEvents, eventsToSend)
    }

    func testEviction() {
        let eventsToRemove = (0...100).map { Event.mock(timestamp: $0) }

        coreMock.removeHandler?(ArraySlice(eventsToRemove))

        XCTAssertEqual(storageMock.removedEvents, eventsToRemove)
    }
}
