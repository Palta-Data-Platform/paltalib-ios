//
//  StructTests.swift
//  EventsGeneratorTests
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation
import XCTest
@testable import EventsGeneratorLib

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
        
        let genratedData = try Data(contentsOf: folderURL.appendingPathComponent("1.swift"))
        let exampleData = try loadExampleData(with: "StructExampleA")
        
        XCTAssertEqual(genratedData, exampleData)
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
                    arguments: [("string", ReturnType(name: "String", isOptional: true))],
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
        
        let genratedData = try Data(contentsOf: folderURL.appendingPathComponent("1.swift"))
        let exampleData = try loadExampleData(with: "StructExampleB")
        
        XCTAssertEqual(genratedData, exampleData)
    }
}
