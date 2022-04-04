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
            groups: ["group": "B"],
            timestamp: 11
        )

        XCTAssertEqual(event.eventType, "someType")
        XCTAssertEqual(event.eventProperties, ["prop": "A"])
        XCTAssertEqual(event.groups, ["group": "B"])
        XCTAssertEqual(event.timestamp, 11)
    }

    func testDefaultTimestamp() {
        let composer = EventComposerImpl()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            groups: [:],
            timestamp: nil
        )

        XCTAssert(abs(event.timestamp - Int(Date().timeIntervalSince1970 * 1000)) < 2)
    }
}
