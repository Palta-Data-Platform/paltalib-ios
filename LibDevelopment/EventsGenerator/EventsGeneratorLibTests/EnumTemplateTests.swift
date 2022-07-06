//
//  EnumTemplateTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
import XCTest
@testable import EventsGeneratorLib

final class EnumTemplateTests: GenerationTests {
    func testEnums() throws {
        let enumsTemplate = EnumsTemplate(
            enums: [
                .init(
                    name: "FirstEnum",
                    cases: [.init(id: 0, name: "one"), .init(id: 1, name: "two")]
                ),
                .init(
                    name: "SecondEnum",
                    cases: [.init(id: 0, name: "one1")]
                )
            ]
        )
        
        let generator = TemplateGenerator(template: enumsTemplate, folderURL: folderURL)
        try generator.generate()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("Enums.swift"))
        let exampleData = try loadExampleData(with: "EnumsExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
}
