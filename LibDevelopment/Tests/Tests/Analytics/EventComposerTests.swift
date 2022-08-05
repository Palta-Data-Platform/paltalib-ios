//
//  EventComposerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 28/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class EventComposerTests: XCTestCase {
    private var sessionIdProvider: SessionManagerMock!
    private var composer: EventComposerImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sessionIdProvider = .init()
        composer = EventComposerImpl(stack: .mock, sessionIdProvider: sessionIdProvider)
    }
    
    func testComposeEvent() {
        mockedTimestamp = 999
        sessionIdProvider.sessionId = 888
        
        let event = composer.composeEvent(
            of: EventTypeMock(),
            with: EventHeaderMock(),
            and: EventPayloadMock(),
            timestamp: nil,
            outOfSession: false
        ) as? BatchEventMock
        
        XCTAssertEqual(event?.common?.timestamp, 999)
        XCTAssertEqual(event?.common?.sessionId, 888)
        XCTAssert(event?.common?.eventType is EventTypeMock)
        XCTAssertNotNil(event?.header)
        XCTAssertNotNil(event?.payload)
    }
    
    func testComposeEventWithTimestamp() {
        mockedTimestamp = 999
        sessionIdProvider.sessionId = 888
        
        let event = composer.composeEvent(
            of: EventTypeMock(),
            with: EventHeaderMock(),
            and: EventPayloadMock(),
            timestamp: 105,
            outOfSession: false
        ) as? BatchEventMock
        
        XCTAssertEqual(event?.common?.timestamp, 105)
        XCTAssertEqual(event?.common?.sessionId, 888)
        XCTAssert(event?.common?.eventType is EventTypeMock)
        XCTAssertNotNil(event?.header)
        XCTAssertNotNil(event?.payload)
    }
    
    func testComposeEventOutOfSession() {
        mockedTimestamp = 999
        sessionIdProvider.sessionId = 888
        
        let event = composer.composeEvent(
            of: EventTypeMock(),
            with: EventHeaderMock(),
            and: EventPayloadMock(),
            timestamp: nil,
            outOfSession: true
        ) as? BatchEventMock
        
        XCTAssertEqual(event?.common?.timestamp, 999)
        XCTAssertEqual(event?.common?.sessionId, -1)
        XCTAssert(event?.common?.eventType is EventTypeMock)
        XCTAssertNotNil(event?.header)
        XCTAssertNotNil(event?.payload)
    }
}
