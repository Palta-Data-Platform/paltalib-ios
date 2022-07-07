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
            and: EventPayloadMock()
        ) as? BatchEventMock
        
        XCTAssertEqual(event?.common?.timestamp, 999)
        XCTAssertEqual(event?.common?.sessionId, 888)
        XCTAssert(event?.common?.eventType is EventTypeMock)
        XCTAssertNotNil(event?.header)
        XCTAssertNotNil(event?.payload)
    }
}
