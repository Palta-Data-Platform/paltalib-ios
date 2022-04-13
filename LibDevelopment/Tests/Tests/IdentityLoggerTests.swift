//
//  IdentityLoggerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 13.04.2022.
//

import Amplitude
import XCTest
@testable import PaltaLibAnalytics

final class IdentityLoggerTests: XCTestCase {
    var eventQueueMock: EventQueueMock!
    var logger: IdentityLogger!

    override func setUpWithError() throws {
        try super.setUpWithError()

        eventQueueMock = EventQueueMock()
        logger = IdentityLogger(eventQueue: eventQueueMock)
    }

    func testInSessionIdentify() {
        let identify = AMPIdentify().add("prop", value: "value" as NSString)!

        logger.identify(identify, outOfSession: false)

        XCTAssertEqual(eventQueueMock.eventType, "$identify")
        XCTAssertEqual(eventQueueMock.eventProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.apiProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.userProperties as? [String: [String: String]], ["$add": ["prop": "value"]])
        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, false)
    }

    func testOutOfSessionIdentify() {
        let identify = AMPIdentify().add("prop", value: "value" as NSString)!

        logger.identify(identify, outOfSession: true)

        XCTAssertEqual(eventQueueMock.eventType, "$identify")
        XCTAssertEqual(eventQueueMock.eventProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.apiProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.userProperties as? [String: [String: String]], ["$add": ["prop": "value"]])
        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, true)
    }

    func testDefaultSessionIdentify() {
        let identify = AMPIdentify().add("prop", value: "value" as NSString)!

        logger.identify(identify)

        XCTAssertEqual(eventQueueMock.outOfSession, false)
    }

    func testInSessionGroupIdentify() {
        let identify = AMPIdentify().add("prop", value: "value" as NSString)!

        logger.groupIdentify(
            groupType: "groupType",
            groupName: "groupName" as NSString,
            groupIdentify: identify,
            outOfSession: false
        )

        XCTAssertEqual(eventQueueMock.eventType, "$groupidentify")
        XCTAssertEqual(eventQueueMock.eventProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups as? [String: String], ["groupType": "groupName"])
        XCTAssertEqual(eventQueueMock.userProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.apiProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties as? [String: [String: String]], ["$add": ["prop": "value"]])
        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, false)
    }

    func testOutOfSessionGroupIdentify() {
        let identify = AMPIdentify().add("prop", value: "value" as NSString)!

        logger.groupIdentify(
            groupType: "groupType",
            groupName: "groupName" as NSString,
            groupIdentify: identify,
            outOfSession: true
        )

        XCTAssertEqual(eventQueueMock.eventType, "$groupidentify")
        XCTAssertEqual(eventQueueMock.eventProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups as? [String: String], ["groupType": "groupName"])
        XCTAssertEqual(eventQueueMock.userProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.apiProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties as? [String: [String: String]], ["$add": ["prop": "value"]])
        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, true)
    }

    func testClearProperties() {
        logger.clearUserProperties()

        XCTAssertEqual(eventQueueMock.eventType, "$identify")
        XCTAssertEqual(eventQueueMock.eventProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.userProperties as? [String: String], ["$clearAll": "-"])
        XCTAssertEqual(eventQueueMock.apiProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties?.isEmpty, true)
        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, false)
    }

    func testSetUserProperties() {
        logger.setUserProperties(
            [
                "property1": 1,
                "property2": 2
            ]
        )

        XCTAssertEqual(eventQueueMock.eventType, "$identify")
        XCTAssertEqual(eventQueueMock.eventProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups?.isEmpty, true)
        XCTAssertEqual(
            eventQueueMock.userProperties as? [String: [String: Int]],
            ["$set": ["property1": 1, "property2": 2]]
        )
        XCTAssertEqual(eventQueueMock.apiProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties?.isEmpty, true)
        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, false)
    }

    func testSetGroup() {
        logger.setGroup(groupType: "type", groupName: "name" as NSString)

        XCTAssertEqual(eventQueueMock.eventType, "$identify")
        XCTAssertEqual(eventQueueMock.eventProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups as? [String: String], ["type": "name"])
        XCTAssertEqual(
            eventQueueMock.userProperties as? [String: [String: String]],
            ["$set": ["type": "name"]]
        )
        XCTAssertEqual(eventQueueMock.apiProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties?.isEmpty, true)
        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, false)
    }
}
