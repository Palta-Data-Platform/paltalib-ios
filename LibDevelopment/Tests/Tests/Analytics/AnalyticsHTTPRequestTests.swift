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
    func testConfigDefaultURL() {
        let request = AnalyticsHTTPRequest.remoteConfig(nil, "api-key-here")

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
    
    func testConfigCustomURL() {
        let request = AnalyticsHTTPRequest.remoteConfig(URL(string: "https://mock.com"), "api-key-here")

        let expectedHeaders = [
            "additionalHeader": "additionalHeaderValue",
            "X-API-Key": "api-key-here"
        ]

        let urlRequest = request.urlRequest(headerFields: ["additionalHeader": "additionalHeaderValue"])

        XCTAssertEqual(urlRequest?.httpMethod, "GET")
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.url, URL(string: "https://mock.com/v1/config"))
        XCTAssertEqual(urlRequest?.timeoutInterval, 10)
        XCTAssertEqual(urlRequest?.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
        XCTAssertNil(urlRequest?.httpBody)
    }

    func testSendEvent() {
        let events: [Event] = [.mock()]
        let request = AnalyticsHTTPRequest.sendEvents(
            URL(string: "https://mock.mock"),
            SendEventsPayload(
                apiKey: "mockKey",
                events: events,
                serviceInfo: .init(
                    uploadTime: .currentTimestamp(),
                    library: .init(name: "PaltaBrain", version: "2.1.5"),
                    telemetry: .mock(),
                    batchId: UUID()
                )
            )
        )

        let expectedHeaders = [
            "additionalHeader": "additionalHeaderValue",
            "X-API-Key": "mockKey",
            "Content-Type": "application/json"
        ]

        let urlRequest = request.urlRequest(headerFields: ["additionalHeader": "additionalHeaderValue"])

        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.url, URL(string: "https://mock.mock/v2/amplitude"))
        XCTAssertEqual(urlRequest?.timeoutInterval, 30)
        XCTAssertEqual(urlRequest?.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
        XCTAssertNotNil(urlRequest?.httpBody)
    }
    
    func testSendEventWithoutBaseURL() {
        let events: [Event] = [.mock()]
        let request = AnalyticsHTTPRequest.sendEvents(
            nil,
            SendEventsPayload(
                apiKey: "mockKey",
                events: events,
                serviceInfo: .init(
                    uploadTime: .currentTimestamp(),
                    library: .init(name: "PaltaBrain", version: "2.1.5"),
                    telemetry: nil,
                    batchId: UUID()
                )
            )
        )

        let urlRequest = request.urlRequest(headerFields: ["additionalHeader": "additionalHeaderValue"])

        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "https://api.paltabrain.com/v2/amplitude"))
        XCTAssertEqual(urlRequest?.timeoutInterval, 30)
        XCTAssertEqual(urlRequest?.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
        XCTAssertNotNil(urlRequest?.httpBody)
    }
}
