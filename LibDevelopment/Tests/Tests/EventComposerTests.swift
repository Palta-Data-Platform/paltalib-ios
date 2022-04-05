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
    func testCompose() {
        let composer = EventComposerImpl()

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
    }

    func testDefaultTimestamp() {
        let composer = EventComposerImpl()

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
