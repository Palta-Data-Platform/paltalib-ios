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
    
    func testBatchCommon() throws {
        let template = BatchCommonTemplate()
        
        let generator = TemplateGenerator(template: template, folderURL: folderURL)
        try generator.generate()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("BatchCommon.swift"))
        let exampleData = try loadExampleData(with: "BatchCommonExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
    
    func testBatchEvent() throws {
        let template = BatchEventTemplate()
        
        let generator = TemplateGenerator(template: template, folderURL: folderURL)
        try generator.generate()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("BatchEvent.swift"))
        let exampleData = try loadExampleData(with: "BatchEventExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
    
    func testContextHelper() throws {
        let template = ContextHelperTemplate()
        
        let generator = TemplateGenerator(template: template, folderURL: folderURL)
        try generator.generate()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("ContextHelper.swift"))
        let exampleData = try loadExampleData(with: "ContextHelperExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
    
    func testStack() throws {
        let template = StackTemplate()
        
        let generator = TemplateGenerator(template: template, folderURL: folderURL)
        try generator.generate()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("Stack.swift"))
        let exampleData = try loadExampleData(with: "StackExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
}
