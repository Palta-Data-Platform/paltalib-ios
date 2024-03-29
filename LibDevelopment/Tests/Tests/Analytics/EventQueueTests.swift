//
//  EventQueueTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import XCTest
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class EventQueueTests: XCTestCase {
    private var coreMock: EventQueueCoreMock!
    private var storageMock: EventStorageMock!
    private var sendControllerMock: BatchSendControllerMock!
    private var eventComposerMock: EventComposerMock!
    private var sessionManagerMock: SessionManagerMock!
    private var contextProviderMock: CurrentContextProviderMock!
    private var backgroundNotifierMock: BackgroundNotifierMock!
    
    private var eventQueue: EventQueueImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        coreMock = .init()
        storageMock = .init()
        eventComposerMock = .init()
        sessionManagerMock = .init()
        sendControllerMock = .init()
        contextProviderMock = .init()
        backgroundNotifierMock = .init()
        
        eventQueue = EventQueueImpl(
            stack: .mock,
            core: coreMock,
            storage: storageMock,
            sendController: sendControllerMock,
            eventComposer: eventComposerMock,
            sessionManager: sessionManagerMock,
            contextProvider: contextProviderMock,
            backgroundNotifier: backgroundNotifierMock
        )
    }
    
    func testAddEvent() {
        let event = EventMock()
        eventQueue.logEvent(event)
        
        XCTAssertNil(eventComposerMock.timestamp)

        XCTAssert(coreMock.addedEvents.first?.event.event is BatchEventMock)
        XCTAssert(storageMock.storedEvents.first?.event.event is BatchEventMock)
        
        XCTAssertEqual(coreMock.addedEvents.first?.event.id, storageMock.storedEvents.first?.event.id)
        XCTAssertEqual(coreMock.addedEvents.first?.contextId, contextProviderMock.currentContextId)
        
        XCTAssertEqual(storageMock.storedEvents.first?.contextId, contextProviderMock.currentContextId)

        XCTAssertEqual(coreMock.addedEvents.count, 1)
        XCTAssertEqual(storageMock.storedEvents.count, 1)
        XCTAssert(sessionManagerMock.refreshSessionCalled)
        XCTAssertFalse(coreMock.forceFlushTriggered)
    }

    func testInit() {
        storageMock.loadedEvents = Array(repeating: .mock(), count: 30)

        eventQueue = .init(
            stack: .mock,
            core: coreMock,
            storage: storageMock,
            sendController: sendControllerMock,
            eventComposer: eventComposerMock,
            sessionManager: sessionManagerMock,
            contextProvider: contextProviderMock,
            backgroundNotifier: backgroundNotifierMock
        )

        try XCTAssertEqual(
            storageMock.loadedEvents.map { try $0.serialize() },
            coreMock.addedEvents.map { try $0.serialize() }
        )
        
        XCTAssertNotNil(coreMock.sendHandler)
        XCTAssertNotNil(coreMock.removeHandler)
        XCTAssertNotNil(sendControllerMock.isReadyCallback)
        XCTAssert(sessionManagerMock.startCalled)
        XCTAssertNotNil(sessionManagerMock.sessionStartLogger)
        XCTAssertFalse(coreMock.forceFlushTriggered)
    }
    
    func testSendWhenAvailable() {
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        sendControllerMock.isReady = true
        
        let result = coreMock.sendHandler?(events, contextId, .mock())
        
        XCTAssertEqual(result, true)
        XCTAssertEqual(sendControllerMock.sentEvents as? [UUID: BatchEventMock], events)
        XCTAssertEqual(sendControllerMock.contextId, contextId)
        XCTAssertFalse(coreMock.forceFlushTriggered)
    }
    
    func testSendWhenNotAvailable() {
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        sendControllerMock.isReady = false
        
        let result = coreMock.sendHandler?(events, contextId, .mock())
        
        XCTAssertEqual(result, false)
        XCTAssertNil(sendControllerMock.sentEvents)
        XCTAssertNil(sendControllerMock.contextId)
        XCTAssertFalse(coreMock.forceFlushTriggered)
    }
    
    func testNotifyWhenAvailable() {
        sendControllerMock.isReadyCallback?()
        
        XCTAssert(coreMock.sendEventsTriggered)
        XCTAssertFalse(coreMock.forceFlushTriggered)
    }

    func testEviction() {
        let eventsToRemove = (0...100).map { StorableEvent.mock(timestamp: $0) }

        coreMock.removeHandler?(ArraySlice(eventsToRemove))

        XCTAssertEqual(storageMock.removedIds, eventsToRemove.map { $0.event.id })
        XCTAssertFalse(coreMock.forceFlushTriggered)
    }
    
    func testSessionStartLogger() {
        sessionManagerMock.sessionStartLogger?(85)
        
        XCTAssertEqual(eventComposerMock.timestamp, 85)
        XCTAssertEqual(coreMock.addedEvents.count, 1)
        XCTAssertEqual(storageMock.storedEvents.count, 1)
        XCTAssertFalse(sessionManagerMock.refreshSessionCalled)
        XCTAssertFalse(coreMock.forceFlushTriggered)
    }
    
    func testBackground() {
        backgroundNotifierMock.listener?()
        
        XCTAssert(coreMock.forceFlushTriggered)
    }
}
