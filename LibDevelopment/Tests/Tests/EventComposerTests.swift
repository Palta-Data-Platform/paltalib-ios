//
//  EventComposerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import XCTest
import PaltaLibCore
@testable import PaltaLibAnalytics

final class EventComposerTests: XCTestCase {
    var sessionManagerMock: SessionManagerMock!

    var composer: EventComposerImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        sessionManagerMock = SessionManagerMock()
        composer = EventComposerImpl(sessionIdProvider: sessionManagerMock)
    }

    func testCompose() {
        sessionManagerMock.sessionId = 845

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: ["prop": "A"],
            apiProperties: ["api": "B"],
            groups: ["group": "C"],
            timestamp: 11
        )

        XCTAssertEqual(event.eventType, "someType")
        XCTAssertEqual(event.eventProperties, ["prop": "A"])
        XCTAssertEqual(event.apiProperties, ["api": "B"])
        XCTAssertEqual(event.groups, ["group": "C"])
        XCTAssertEqual(event.timestamp, 11)
        XCTAssertEqual(event.sessionId, 845)
    }

    func testDefaultTimestamp() {
        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            timestamp: nil
        )

        XCTAssert(abs(event.timestamp - .currentTimestamp()) < 2)
    }
}
