//
//  AnyEncodableTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation
import XCTest

final class AnyEncodableTests: XCTestCase {
    func testEncoding() throws {
        struct AStruct: Codable, Equatable {
            let integer: Int
            let string: String
        }

        let originalStruct = AStruct(integer: 234, string: "Some string")
        let anyEncodable = originalStruct.typeErased

        let recoveredStruct = try JSONDecoder().decode(
            AStruct.self,
            from: JSONEncoder().encode(anyEncodable)
        )

        XCTAssertEqual(originalStruct, recoveredStruct)
    }
}
