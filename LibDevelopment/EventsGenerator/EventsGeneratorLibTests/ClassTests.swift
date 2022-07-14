//
//  ClassTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 04/07/2022.
//

import Foundation
import XCTest
@testable import EventsGeneratorStatic

final class ClassTests: GenerationTests {
    func testA() throws {
        let classs = Class(
            visibility: .open,
            name: "AClass",
            isFinal: true,
            inheritance: nil,
            conformances: nil,
            properties: [
                .init(
                    visibility: .public,
                    name: "int",
                    isMutable: true,
                    returnType: ReturnType(type: Int.self),
                    didSet: DidSet(statements: ["print(int)"]),
                    defaultValue: "0"
                )
            ],
            inits: [.public]
        )
        
        try CodeGenerator
            .init(folderURL: folderURL)
            .genrateCode(
                filename: "1",
                header: "This is my header\nA new line",
                imports: [],
                statements: [classs]
            )
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("1.swift"))
        let exampleData = try loadExampleData(with: "ClassExampleA")
        
        XCTAssertEqual(generatedData, exampleData)
    }
    
    func testB() throws {
        let classs = Class(
            visibility: .open,
            name: "BClass",
            isFinal: false,
            inheritance: "NSNumber",
            conformances: nil,
            properties: [
                .init(
                    visibility: .fileprivate,
                    name: "int",
                    isMutable: true,
                    returnType: ReturnType(name: "Int", isOptional: true)
                )
            ],
            inits: [
                .init(
                    visibility: .internal,
                    isConvenience: true,
                    arguments: [Init.Argument(label: "int", type: ReturnType(name: "Int", isOptional: true))],
                    statements: ["self.int = int"]
                )
            ]
        )
        
        try CodeGenerator
            .init(folderURL: folderURL)
            .genrateCode(
                filename: "1",
                header: "This is my header\nA new line",
                imports: ["Foundation"],
                statements: [classs]
            )
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("1.swift"))
        let exampleData = try loadExampleData(with: "ClassExampleB")
        
        XCTAssertEqual(generatedData, exampleData)
    }
    
    func testC() throws {
        let classs = Class(
            visibility: .fileprivate,
            name: "BClass",
            isFinal: false,
            inheritance: nil,
            conformances: ["Equatable", "Hashable"],
            properties: [
                .init(
                    visibility: .fileprivate,
                    name: "int",
                    isMutable: false,
                    returnType: ReturnType(name: "Int", isOptional: true)
                )
            ],
            inits: [
                .init(
                    visibility: .internal,
                    isRequired: true,
                    arguments: [Init.Argument(label: "int", type: ReturnType(name: "Int", isOptional: true))],
                    statements: ["self.int = int"]
                )
            ]
        )
        
        try CodeGenerator
            .init(folderURL: folderURL)
            .genrateCode(
                filename: "1",
                header: "This is my header\nA new line",
                imports: ["Foundation"],
                statements: [classs]
            )
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("1.swift"))
        let exampleData = try loadExampleData(with: "ClassExampleC")
        
        XCTAssertEqual(generatedData, exampleData)
    }
    
    func testD() throws {
        let classs = Class(
            visibility: .public,
            name: "DClass",
            isFinal: true,
            inheritance: "NSNumber",
            conformances: ["Equatable", "Hashable"],
            properties: [],
            inits: [
                .init(visibility: .public, isOverride: true)
            ]
        )
        
        try CodeGenerator
            .init(folderURL: folderURL)
            .genrateCode(
                filename: "1",
                header: "This is my header\nA new line",
                imports: ["Foundation"],
                statements: [classs]
            )
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("1.swift"))
        let exampleData = try loadExampleData(with: "ClassExampleD")
        
        XCTAssertEqual(generatedData, exampleData)
    }
}
