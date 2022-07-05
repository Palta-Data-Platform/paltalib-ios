//
//  HeaderTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
import XCTest
@testable import EventsGeneratorLib

final class HeaderTests: GenerationTests {
    func testHeader() throws {
        let contextTemplate = EventHeaderTemplate(
            elements: [
                .init(
                    protoPrefix: "EventHeader",
                    entityName: "Parent",
                    properties: [("parent_elements", .array(.string))]
                )
            ]
        )
        
        let generator = TemplateGenerator(template: contextTemplate, folderURL: folderURL)
        try generator.generate()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("EventHeader.swift"))
        let exampleData = try loadExampleData(with: "EventHeaderExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
}
