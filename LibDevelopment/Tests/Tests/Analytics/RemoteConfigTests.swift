//
//  RemoteConfigTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 08/07/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class RemoteConfigTests: XCTestCase {
    func testDecode() throws {
        let jsonString = """
{"eventUploadThreshold":3094,"eventUploadMaxBatchSize":1289,"eventMaxCount":335,"eventUploadPeriod":30,"url":"http:\\/\\/hello.me","minTimeBetweenSessions":124}
"""
        let data = jsonString.data(using: .utf8)!
        
        let config = try JSONDecoder().decode(RemoteConfig.self, from: data)
        
        XCTAssertEqual(config.eventUploadThreshold, 3094)
        XCTAssertEqual(config.eventUploadMaxBatchSize, 1289)
        XCTAssertEqual(config.eventMaxCount, 335)
        XCTAssertEqual(config.url, URL(string: "http://hello.me"))
        XCTAssertEqual(config.minTimeBetweenSessions, 124)
    }
}
