//
//  EventSendErrorTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import XCTest

final class EventSendErrorTests: XCTestCase {
    func testTimeout() {
        XCTAssertTrue(EventSendError.timeout.requiresRetry)
    }

    func testNoInternet() {
        XCTAssertTrue(EventSendError.noInternet.requiresRetry)
    }

    func testServerError() {
        XCTAssertTrue(EventSendError.serverError.requiresRetry)
    }

    func testBadRequest() {
        XCTAssertFalse(EventSendError.badRequest.requiresRetry)
    }

    func testUnknown() {
        XCTAssertFalse(EventSendError.unknown.requiresRetry)
    }
    
}
