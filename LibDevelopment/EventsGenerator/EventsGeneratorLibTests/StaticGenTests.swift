//
//  StaticGenTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 10/08/2022.
//

import XCTest
@testable import EventsGeneratorStatic

final class StaticGenTests: GenerationTests {
    func testBatch() throws {
        let template = BatchTemplate()
        
        let generator = TemplateGenerator(template: template, folderURL: folderURL)
        try generator.generate()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("Batch.swift"))
        let exampleData = try loadExampleData(with: "BatchExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
}
