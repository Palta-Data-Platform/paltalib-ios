//
//  EventComposer2Tests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 28/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class EventComposer2Tests: XCTestCase {
    private var sessionIdProvider: SessionManagerMock!
    private var composer: EventComposer2Impl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sessionIdProvider = .init()
        composer = EventComposer2Impl(stack: .mock, sessionIdProvider: sessionIdProvider)
    }
    
    func testComposeEvent() {
        mockedTimestamp = 999
        sessionIdProvider.sessionId = 888
        
        let event = composer.composeEvent(
            of: EventTypeMock().boxed,
            with: EventHeaderMock(),
            and: EventPayloadMock()
        ) as? BatchEventMock
        
        XCTAssertEqual(event?.common?.timestamp, 999)
        XCTAssertEqual(event?.common?.sessionId, 888)
        XCTAssertNotNil(event?.common?.eventType.unbox(as: EventTypeMock.self))
        XCTAssertNotNil(event?.header)
        XCTAssertNotNil(event?.payload)
    }
}
