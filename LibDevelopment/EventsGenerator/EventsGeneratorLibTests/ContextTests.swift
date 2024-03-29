//
//  ContextTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
@testable import EventsGeneratorStatic
import XCTest

final class ContextTests: GenerationTests {
    func testContext() throws {
        let contextTemplate = ContextTemplate(
            elements: [
                .init(
                    protoPrefix: "Context",
                    entityName: "Application",
                    properties: [("appID", .string), ("app_version", .string)]
                ),
                
                .init(
                    protoPrefix: "Context",
                    entityName: "Device",
                    properties: [("device_brand", .string), ("device_model", .string)]
                )
            ]
        )
        
        let generator = TemplateGenerator(template: contextTemplate, folderURL: folderURL)
        try generator.generate()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("Context.swift"))
        let exampleData = try loadExampleData(with: "ContextExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
}
