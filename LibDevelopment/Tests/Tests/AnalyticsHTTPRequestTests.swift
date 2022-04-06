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
}
