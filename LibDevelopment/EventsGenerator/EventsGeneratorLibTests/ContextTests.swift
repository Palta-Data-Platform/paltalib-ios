//
//  ContextTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
@testable import EventsGeneratorLib
import XCTest

final class ContextTests: GenerationTests {
    func testContext() throws {
        let contextTemplate = ContextTemplate(
            elements: [
                .init(
                    entityName: "Application",
                    properties: [("appID", .string), ("appVersion", .string)]
                ),
                
                .init(
                    entityName: "Device",
                    properties: [("deviceBrand", .string), ("deviceModel", .string)]
                )
            ]
        )
        
        let generator = TemplateGenerator(template: contextTemplate, folderURL: folderURL)
        try generator.generate()
        
        print(folderURL!)
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("Context.swift"))
        let exampleData = try loadExampleData(with: "ContextExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
}
