//
//  AnalyticsHTTPRequestTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class GetConfigRequestTests: XCTestCase {
    func testDefaultHost() {
        let request = GetConfigRequest(host: nil, apiKey: "api-key-here")

        let expectedHeaders = [
            "additionalHeader": "additionalHeaderValue",
            "X-API-Key": "api-key-here"
        ]

        let urlRequest = request.urlRequest(headerFields: ["additionalHeader": "additionalHeaderValue"])

        XCTAssertEqual(urlRequest?.httpMethod, "GET")
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.url, URL(string: "https://api.paltabrain.com/v2/config"))
        XCTAssertEqual(urlRequest?.timeoutInterval, 10)
        XCTAssertEqual(urlRequest?.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
        XCTAssertNil(urlRequest?.httpBody)
    }
    
    func testCustomHost() {
        let request = GetConfigRequest(host: URL(string: "http://test.host.com"), apiKey: "api-key-here")

        let expectedHeaders = [
            "additionalHeader": "additionalHeaderValue",
            "X-API-Key": "api-key-here"
        ]

        let urlRequest = request.urlRequest(headerFields: ["additionalHeader": "additionalHeaderValue"])

        XCTAssertEqual(urlRequest?.httpMethod, "GET")
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.url, URL(string: "http://test.host.com/v2/config"))
        XCTAssertEqual(urlRequest?.timeoutInterval, 10)
        XCTAssertEqual(urlRequest?.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
        XCTAssertNil(urlRequest?.httpBody)
    }
}
