//
//  PropertyTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 04/07/2022.
//

import XCTest
@testable import EventsGeneratorLib

final class PropertyTests: XCTestCase {
    func testSimpleLet() {
        let property = EventsGeneratorLib.Property(
            visibility: .internal,
            name: "int",
            isMutable: false,
            returnType: ReturnType(type: Int.self)
        )
        
        let stringValue = property.stringValue(for: 0)
        
        let expectedString = "internal let int: Int\n"
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testSimpleVar() {
        let property = EventsGeneratorLib.Property(
            visibility: .internal,
            name: "int",
            isMutable: true,
            returnType: ReturnType(type: Int.self)
        )
        
        let stringValue = property.stringValue(for: 0)
        
        let expectedString = "internal var int: Int\n"
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testGetter() {
        let property = EventsGeneratorLib.Property(
            visibility: .internal,
            name: "int",
            isMutable: true,
            returnType: ReturnType(type: Int.self),
            getter: Getter(statements: ["return 0"])
        )
        
        let stringValue = property.stringValue(for: 0)
        
        let expectedString = """
internal var int: Int {
    get {
        return 0
    }
}\u{20}

"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testGetterSetter() {
        let property = EventsGeneratorLib.Property(
            visibility: .internal,
            name: "int",
            isMutable: true,
            returnType: ReturnType(type: Int.self),
            setter: Setter(statements: ["_ = newValue"]),
            getter: Getter(statements: ["return 0"])
        )
        
        let stringValue = property.stringValue(for: 0)
        
        let expectedString = """
internal var int: Int {
    set {
        _ = newValue
    }

    get {
        return 0
    }
}\u{20}

"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testDefaultValue() {
        let property = EventsGeneratorLib.Property(
            visibility: .private,
            name: "int",
            returnType: ReturnType(type: Int.self),
            defaultValue: "0"
        )
        
        let stringValue = property.stringValue(for: 0)
        
        let expectedString = """
private let int: Int = 0

"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
    
    func testStatic() {
        let property = Property(visibility: .public, isStatic: true, name: "prop", returnType: ReturnType(type: String.self))
        
        let stringValue = property.stringValue(for: 0)
        
        let expectedString = """
public static let prop: String

"""
        
        XCTAssertEqual(stringValue, expectedString)
    }
}
