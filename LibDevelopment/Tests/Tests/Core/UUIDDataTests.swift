//
//  UUIDDataTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/11/2022.
//

import Foundation
import PaltaLibCore
import XCTest

final class UUIDDataTests: XCTestCase {
    func testConvert() {
        let uuid = UUID()
        let data = uuid.data
        let recoveredUUID = UUID(data: data)
        
        XCTAssertEqual(recoveredUUID, uuid)
    }
}
