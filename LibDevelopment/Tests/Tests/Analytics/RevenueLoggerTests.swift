//
//  RevenueLoggerTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 13.04.2022.
//

import XCTest
import Amplitude
@testable import PaltaLibAnalytics

final class RevenueLoggerTests: XCTestCase {
    var eventQueueMock: EventQueueMock!
    var logger: RevenueLogger!

    override func setUpWithError() throws {
        try super.setUpWithError()

        eventQueueMock = EventQueueMock()
        logger = RevenueLogger(eventQueue: eventQueueMock)
    }

    func testLogRevenue() {
        logger.logRevenue(
            "product-id",
            quantity: 22,
            price: 56 as NSNumber,
            receipt: Data(repeating: 4, count: 16)
        )

        XCTAssertEqual(eventQueueMock.eventType, "revenue_amount")
        XCTAssertEqual(eventQueueMock.eventProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.userProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties?.isEmpty, true)

        XCTAssertEqual(eventQueueMock.apiProperties?["special"] as? String, "revenue_amount")
        XCTAssertEqual(eventQueueMock.apiProperties?["productId"] as? String, "product-id")
        XCTAssertEqual(eventQueueMock.apiProperties?["quantity"] as? Int, 22)
        XCTAssertEqual(eventQueueMock.apiProperties?["price"] as? Int, 56)
        XCTAssertEqual(eventQueueMock.apiProperties?["receipt"] as? String, "BAQEBAQEBAQEBAQEBAQEBA==")

        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, false)
    }

    func testLogRevenueWithNils() {
        logger.logRevenue(
            nil,
            quantity: 22,
            price: 56 as NSNumber,
            receipt: nil
        )

        XCTAssertEqual(eventQueueMock.eventType, "revenue_amount")
        XCTAssertEqual(eventQueueMock.eventProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.userProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties?.isEmpty, true)

        XCTAssertEqual(eventQueueMock.apiProperties?["special"] as? String, "revenue_amount")
        XCTAssertEqual(eventQueueMock.apiProperties?["quantity"] as? Int, 22)
        XCTAssertEqual(eventQueueMock.apiProperties?["price"] as? Int, 56)
        XCTAssertNil(eventQueueMock.apiProperties?["receipt"])
        XCTAssertNil(eventQueueMock.apiProperties?["productId"])

        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, false)
    }

    func testRevenueV2() {
        logger
            .logRevenueV2(
                AMPRevenue()
                    .setReceipt(Data(repeating: 4, count: 8))
                    .setPrice(66)
                    .setQuantity(4)
                    .setProductIdentifier("product")
            )

        XCTAssertEqual(eventQueueMock.eventType, "revenue_amount")
        XCTAssertEqual(eventQueueMock.apiProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groups?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.userProperties?.isEmpty, true)
        XCTAssertEqual(eventQueueMock.groupProperties?.isEmpty, true)

        XCTAssertEqual(eventQueueMock.eventProperties?["$quantity"] as? Int, 4)
        XCTAssertEqual(eventQueueMock.eventProperties?["$price"] as? Int, 66)
        XCTAssertEqual(eventQueueMock.eventProperties?["$receipt"] as? String, "BAQEBAQEBAQ=")
        XCTAssertEqual(eventQueueMock.eventProperties?["$productId"] as? String, "product")

        XCTAssertNil(eventQueueMock.timestamp)
        XCTAssertEqual(eventQueueMock.outOfSession, false)
    }

    func testRevenueV2Invalid() {
        logger
            .logRevenueV2(
                AMPRevenue()
                    .setReceipt(Data(repeating: 4, count: 8))
                    .setQuantity(4)
                    .setProductIdentifier("product")
            )

        XCTAssertNil(eventQueueMock.eventType)
    }
}
