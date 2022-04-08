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
    var userPropertiesMock: UserPropertiesKeeperMock!

    var composer: EventComposerImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        sessionManagerMock = SessionManagerMock()
        userPropertiesMock = UserPropertiesKeeperMock()
        composer = EventComposerImpl(
            sessionIdProvider: sessionManagerMock,
            userPropertiesProvider: userPropertiesMock
        )
    }

    func testCompose() {
        sessionManagerMock.sessionId = 845
        userPropertiesMock.userId = "sample-user-id"
        userPropertiesMock.deviceId = UUID()

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
        XCTAssertEqual(event.userId, "sample-user-id")
        XCTAssertEqual(event.deviceId, userPropertiesMock.deviceId)
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
