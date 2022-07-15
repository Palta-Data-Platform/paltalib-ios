//
//  BatchSendRequestTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import XCTest
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class BatchSendRequestTests: XCTestCase {
    func testBuildRequest() {
        let data = Data((0...20).map { _ in UInt8.random(in: UInt8.min...UInt8.max) })
        let request = BatchSendRequest(
            url: URL(string: "ftp://mock.url/path")!,
            time: 878,
            data: data
        )
        
        let urlRequest = request.urlRequest(headerFields: ["DEFAULT_HEADER": "DEFAULT_HEADER_VALUE"])
        
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.url, URL(string: "ftp://mock.url/path"))
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "X-Client-Upload-TS": "878",
                "DEFAULT_HEADER": "DEFAULT_HEADER_VALUE",
                "Content-Type": "application/protobuf"
            ]
        )
        XCTAssertEqual(urlRequest?.httpBody, data)
    }
}
