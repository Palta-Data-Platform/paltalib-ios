//
//  EventQueue2Tests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics
import AnalyticsDTOExample

final class EventQueue2Tests: XCTestCase {
    private var coreMock: EventQueue2CoreMock!
    private var storageMock: EventStorage2Mock!
    private var sendControllerMock: BatchSendControllerMock!
    private var eventComposerMock: EventComposer2Mock!
    private var sessionManagerMock: SessionManagerMock!
    private var contextProviderMock: CurrentContextProviderMock!
    
    private var eventQueue: EventQueue2Impl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        coreMock = .init()
        storageMock = .init()
        eventComposerMock = .init()
        sessionManagerMock = .init()
        sendControllerMock = .init()
        contextProviderMock = .init()
        
        eventQueue = EventQueue2Impl(
            core: coreMock,
            storage: storageMock,
            sendController: sendControllerMock,
            eventComposer: eventComposerMock,
            sessionManager: sessionManagerMock,
            contextProvider: contextProviderMock
        )
    }
    
    func testAddEvent() {
        let event = PageOpenEvent(header: .init(pora: .init(designID: "")), pageID: "", title: "")
        eventQueue.logEvent(event, outOfSession: false)

        XCTAssert(coreMock.addedEvents.first?.event.event is BatchEventMock)
        XCTAssert(storageMock.storedEvents.first?.event.event is BatchEventMock)
        
        XCTAssertEqual(coreMock.addedEvents.first?.event.id, storageMock.storedEvents.first?.event.id)
        XCTAssertEqual(coreMock.addedEvents.first?.contextId, contextProviderMock.currentContextId)
        
        XCTAssertEqual(storageMock.storedEvents.first?.contextId, contextProviderMock.currentContextId)

        XCTAssertEqual(coreMock.addedEvents.count, 1)
        XCTAssertEqual(storageMock.storedEvents.count, 1)
        XCTAssert(sessionManagerMock.refreshSessionCalled)
    }

    func testAddOutOfSessionEvent() {
        let event = PageOpenEvent(header: .init(pora: .init(designID: "")), pageID: "", title: "")
        eventQueue.logEvent(event, outOfSession: true)

        XCTAssertFalse(sessionManagerMock.refreshSessionCalled)
    }

    func testInit() {
        storageMock.loadedEvents = Array(repeating: .mock(), count: 30)

        eventQueue = .init(
            core: coreMock,
            storage: storageMock,
            sendController: sendControllerMock,
            eventComposer: eventComposerMock,
            sessionManager: sessionManagerMock,
            contextProvider: contextProviderMock
        )

        try XCTAssertEqual(
            storageMock.loadedEvents.map { try $0.serialize() },
            coreMock.addedEvents.map { try $0.serialize() }
        )
        
        XCTAssertNotNil(coreMock.sendHandler)
        XCTAssertNotNil(coreMock.removeHandler)
        XCTAssertNotNil(sendControllerMock.isReadyCallback)
        XCTAssert(sessionManagerMock.startCalled)
    }
    
    func testSendWhenAvailable() {
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        sendControllerMock.isReady = true
        
        let result = coreMock.sendHandler?(events, contextId, .mock())
        
        XCTAssertEqual(result, true)
        XCTAssertEqual(sendControllerMock.sentEvents as? [UUID: BatchEventMock], events)
        XCTAssertEqual(sendControllerMock.contextId, contextId)
    }
    
    func testSendWhenNotAvailable() {
        let contextId = UUID()
        let events = [UUID(): BatchEventMock()]
        sendControllerMock.isReady = false
        
        let result = coreMock.sendHandler?(events, contextId, .mock())
        
        XCTAssertEqual(result, false)
        XCTAssertNil(sendControllerMock.sentEvents)
        XCTAssertNil(sendControllerMock.contextId)
    }
    
    func testNotifyWhenAvailable() {
        sendControllerMock.isReadyCallback?()
        
        XCTAssert(coreMock.sendEventsTriggered)
    }

    func testEviction() {
        let eventsToRemove = (0...100).map { StorableEvent.mock(timestamp: $0) }

        coreMock.removeHandler?(ArraySlice(eventsToRemove))

        XCTAssertEqual(storageMock.removedIds, eventsToRemove.map { $0.event.id })
    }
}
