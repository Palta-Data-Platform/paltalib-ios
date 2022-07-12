//
//  TypealiasTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 06/07/2022.
//

import Foundation
import XCTest
@testable import EventsGeneratorStatic

final class TypealiasTests: XCTestCase {
    func testTypealias() {
        let alias = Typealias(
            visibility: .public,
            firstType: ReturnType(name: "AString"),
            secondType: ReturnType(type: String.self)
        )
        
        let stringValue = alias.stringValue(for: 1)
        
        let expectedValue = "    public typealias AString = String"
        
        XCTAssertEqual(stringValue, expectedValue)
    }
}
