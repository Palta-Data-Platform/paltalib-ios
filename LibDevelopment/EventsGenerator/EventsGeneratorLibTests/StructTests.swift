//
//  StructTests.swift
//  EventsGeneratorTests
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation
import XCTest
@testable import EventsGeneratorStatic

final class StructTests: GenerationTests {
    func testA() throws {
        let structt = Struct(visibility: .private, name: "AStruct")
        
        try CodeGenerator
            .init(folderURL: folderURL)
            .genrateCode(
                filename: "1",
                header: "This is my header\nA new line",
                imports: ["Foundation"],
                statements: [structt]
            )
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("1.swift"))
        let exampleData = try loadExampleData(with: "StructExampleA")
        
        XCTAssertEqual(generatedData, exampleData)
    }
    
    func testB() throws {
        let structt = Struct(
            visibility: .private,
            name: "AStruct",
            properties: [.init(visibility: .public, name: "string", returnType: ReturnType(type: String.self))],
            inits: [
                .init(
                    visibility: .fileprivate,
                    throws: true,
                    arguments: [Init.Argument(label: "string", type: ReturnType(name: "String", isOptional: true))],
                    statements: ["self.string = string ?? \"\""]
                )
            ],
            methods: [.init(visibility: .internal, name: "doNothing")]
        )
        
        try CodeGenerator
            .init(folderURL: folderURL)
            .genrateCode(
                filename: "1",
                header: "This is my header\nA new line",
                imports: ["Foundation", "UIKit"],
                statements: [structt]
            )
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("1.swift"))
        let exampleData = try loadExampleData(with: "StructExampleB")
        
        XCTAssertEqual(generatedData, exampleData)
    }
}
