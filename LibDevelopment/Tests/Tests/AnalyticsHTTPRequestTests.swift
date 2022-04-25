//
//  AnalyticsHTTPRequestTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class AnalyticsHTTPRequestTests: XCTestCase {
    func testConfig() {
        let request = AnalyticsHTTPRequest.remoteConfig("api-key-here")

        let expectedHeaders = [
            "additionalHeader": "additionalHeaderValue",
            "X-API-Key": "api-key-here"
        ]

        let urlRequest = request.urlRequest(headerFields: ["additionalHeader": "additionalHeaderValue"])

        XCTAssertEqual(urlRequest?.httpMethod, "GET")
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.url, URL(string: "https://api.paltabrain.com/v1/config"))
        XCTAssertEqual(urlRequest?.timeoutInterval, 10)
        XCTAssertEqual(urlRequest?.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
        XCTAssertNil(urlRequest?.httpBody)
    }

    func testSendEvent() {
        let events: [Event] = [.mock()]
        let request = AnalyticsHTTPRequest.sendEvents(
            SendEventsPayload(apiKey: "mockKey", events: events, serviceInfo: .init(telemetry: nil))
        )

        let expectedHeaders = [
            "additionalHeader": "additionalHeaderValue",
            "X-API-Key": "mockKey",
            "Content-Type": "application/json"
        ]

        let urlRequest = request.urlRequest(headerFields: ["additionalHeader": "additionalHeaderValue"])

        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.url, URL(string: "https://api.paltabrain.com/events-v2"))
        XCTAssertEqual(urlRequest?.timeoutInterval, 30)
        XCTAssertEqual(urlRequest?.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
        XCTAssertNotNil(urlRequest?.httpBody)
    }
}
