//
//  EventQueueTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import XCTest
@testable import PaltaLibAnalytics

final class EventQueueTests: XCTestCase {
    var eventQueue: EventQueueImpl!
    var coreMock: EventQueueCoreMock!
    var timerMock: TimerMock!
    var storageMock: EventStorageMock!
    var senderMock: EventSenderMock!
    var composerMock: EventComposerMock!
    var sessionManagerMock: SessionManagerMock!

    override func setUpWithError() throws {
        try super.setUpWithError()

        coreMock = .init()
        timerMock = .init()
        storageMock = .init()
        senderMock = .init()
        composerMock = .init()
        sessionManagerMock = .init()

        eventQueue = .init(
            core: coreMock,
            storage: storageMock,
            sender: senderMock,
            eventComposer: composerMock,
            sessionManager: sessionManagerMock,
            timer: timerMock
        )
    }

    func testAddEvent() {
        eventQueue.logEvent(
            eventType: "event-type",
            eventProperties: ["prop": "1"],
            groups: ["group": 2],
            userProperties: ["user": 3],
            groupProperties: ["groupP": 4],
            timestamp: 22
        )

        XCTAssertEqual(composerMock.eventType, "event-type")
        XCTAssertEqual(composerMock.eventProperties as? [String: String], ["prop": "1"])
        XCTAssertEqual(composerMock.groups as? [String: Int], ["group": 2])
        XCTAssertEqual(composerMock.userProperties as? [String: Int], ["user": 3])
        XCTAssertEqual(composerMock.groupProperties as? [String: Int], ["groupP": 4])
        XCTAssertEqual(composerMock.timestamp, 22)
        XCTAssertEqual(composerMock.outOfSession, false)
        XCTAssert(composerMock.apiProperties?.isEmpty == true)

        XCTAssertEqual(coreMock.addedEvents, [.mock()])
        XCTAssertEqual(storageMock.addedEvents, [.mock()])
        XCTAssertNil(senderMock.sentEvents)
        XCTAssertNil(timerMock.passedInterval)
        XCTAssert(sessionManagerMock.refreshSessionCalled)
    }

    func testAddOutOfSessionEvent() {
        eventQueue.logEvent(
            eventType: "event-type",
            eventProperties: ["prop": "1"],
            groups: ["group": 2],
            timestamp: 22,
            outOfSession: true
        )

        XCTAssertEqual(composerMock.outOfSession, true)

        XCTAssertEqual(coreMock.addedEvents, [.mock()])
        XCTAssertEqual(storageMock.addedEvents, [.mock()])
        XCTAssertNil(senderMock.sentEvents)
        XCTAssertNil(timerMock.passedInterval)
        XCTAssert(sessionManagerMock.refreshSessionCalled)
    }

    func testInit() {
        storageMock.eventsToLoad = Array(repeating: .mock(), count: 30)

        eventQueue = .init(
            core: coreMock,
            storage: storageMock,
            sender: senderMock,
            eventComposer: composerMock,
            sessionManager: sessionManagerMock,
            timer: timerMock
        )

        XCTAssertEqual(storageMock.eventsToLoad, coreMock.addedEvents)
        XCTAssertNotNil(coreMock.sendHandler)
        XCTAssertNotNil(coreMock.removeHandler)
        XCTAssert(sessionManagerMock.startCalled)
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

    func testSessionEvent() {
        sessionManagerMock.sessionEventLogger?("some event", 234)

        XCTAssertEqual(coreMock.addedEvents.count, 1)
        XCTAssertEqual(coreMock.addedEvents.first?.eventType, "some event")
        XCTAssertEqual(coreMock.addedEvents.first?.timestamp, 234)
        XCTAssertEqual(coreMock.addedEvents.first?.apiProperties, ["special": "some event"])
        XCTAssertEqual(coreMock.addedEvents.first?.userProperties, [:])
        XCTAssertEqual(coreMock.addedEvents.first?.eventProperties, [:])
        XCTAssertEqual(coreMock.addedEvents.first?.groups, [:])
        XCTAssertEqual(coreMock.addedEvents.first?.groupProperties, [:])

        XCTAssertEqual(storageMock.addedEvents.count, 1)
        XCTAssertEqual(storageMock.addedEvents.first?.eventType, "some event")
        XCTAssertEqual(storageMock.addedEvents.first?.timestamp, 234)
        XCTAssertEqual(storageMock.addedEvents.first?.apiProperties, ["special": "some event"])
        XCTAssertEqual(storageMock.addedEvents.first?.userProperties, [:])
        XCTAssertEqual(storageMock.addedEvents.first?.eventProperties, [:])
        XCTAssertEqual(storageMock.addedEvents.first?.groups, [:])
        XCTAssertEqual(storageMock.addedEvents.first?.groupProperties, [:])

        XCTAssert(storageMock.removedEvents.isEmpty)
        XCTAssertNil(senderMock.sentEvents)
    }
}
