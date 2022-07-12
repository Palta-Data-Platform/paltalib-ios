//
//  MethodTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 04/07/2022.
//

import XCTest
@testable import EventsGeneratorStatic

final class MethodTests: XCTestCase {
    func testEmptyVoid() {
        let method = EventsGeneratorStatic.Method(
            visibility: .public,
            name: "doSomething",
            statements: ["print(\"Hello world\")", "print(\"Again\")"]
        )
        
        let stringValue = method.stringValue(for: 0)
        
        let expectedString = """
public func doSomething() {
    print("Hello world")
    print("Again")
}
"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testParameters() {
        let method = EventsGeneratorStatic.Method(
            visibility: .public,
            name: "make",
            arguments: [
                .init(label: "_", name: "x", type: ReturnType(type: Int.self)),
                .init(label: "and", name: "y", type: ReturnType(name: "String", isOptional: true)),
                .init(name: "z", type: ReturnType(name: "Bool"), defaultValue: "false")
            ],
            statements: ["print(\"Hello world\")", "print(\"Again\")"]
        )
        
        let stringValue = method.stringValue(for: 0)
        
        let expectedString = """
public func make(_ x: Int, and y: String?, z: Bool = false) {
    print("Hello world")
    print("Again")
}
"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testThrowsVoid() {
        let method = EventsGeneratorStatic.Method(
            visibility: .internal,
            throws: true,
            name: "make"
        )
        
        let stringValue = method.stringValue(for: 0)
        
        let expectedString = """
internal func make() throws {
}
"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testThrowsReturnValue() {
        let method = EventsGeneratorStatic.Method(
            visibility: .internal,
            throws: true,
            name: "make",
            returnValue: ReturnType(type: Int.self)
        )
        
        let stringValue = method.stringValue(for: 0)
        
        let expectedString = """
internal func make() throws -> Int {
}
"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testReturnValue() {
        let method = EventsGeneratorStatic.Method(
            visibility: .internal,
            throws: false,
            name: "make",
            returnValue: ReturnType(name: "String", isOptional: true)
        )
        
        let stringValue = method.stringValue(for: 0)
        
        let expectedString = """
internal func make() -> String? {
}
"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testOverride() {
        let method = EventsGeneratorStatic.Method(
            visibility: .public,
            isOverride: true,
            name: "make"
        )
        
        let stringValue = method.stringValue(for: 0)
        
        let expectedString = """
public override func make() {
}
"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
}
