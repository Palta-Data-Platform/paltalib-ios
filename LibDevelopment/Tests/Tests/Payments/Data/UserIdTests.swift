//
//  UserIdTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 11/07/2022.
//

import Foundation
import XCTest
import PaltaLibCore
@testable import PaltaLibPayments

final class UserIdTests: XCTestCase {
    private let encoder = JSONEncoder().do {
        $0.outputFormatting = .sortedKeys
    }
    
    func testUUID() throws {
        let uuid = UUID()
        
        let id = UserId.uuid(uuid)
        
        let jsonString = try String(data: encoder.encode(id), encoding: .utf8)
        let expectedJsonString = "{\"type\":\"merchant-uuid\",\"value\":\"\(uuid)\"}"
        
        XCTAssertEqual(id.stringValue, uuid.uuidString)
        XCTAssertEqual(jsonString, expectedJsonString)
    }
    
    func testString() throws {
        let string = UUID().uuidString
        
        let id = UserId.string(string)
        
        let jsonString = try String(data: encoder.encode(id), encoding: .utf8)
        let expectedJsonString = "{\"type\":\"merchant-str\",\"value\":\"\(string)\"}"
        
        XCTAssertEqual(id.stringValue, string)
        XCTAssertEqual(jsonString, expectedJsonString)
    }
}
