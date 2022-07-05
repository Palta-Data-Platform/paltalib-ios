//
//  End2EndTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
import XCTest
@testable import EventsGeneratorLib

final class End2EndTests: GenerationTests {
    func testContext() throws {
        try generateFiles()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("Context.swift"))
        let exampleData = try loadExampleData(with: "ContextExampleE2E")
        
        XCTAssertEqual(generatedData, exampleData)
    }
    
    func testEventHeader() throws {
        try generateFiles()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("EventHeader.swift"))
        let exampleData = try loadExampleData(with: "EventHeaderE2E")
        
        XCTAssertEqual(generatedData, exampleData)
    }
    
    private func generateFiles() throws {
        let yamlURL = Bundle
            .init(
                for: StructTests.self
            )
            .url(
                forResource: "config",
                withExtension: "yaml",
                subdirectory: "Examples"
            )!
        
        try YAMLBasedEventsGenerator(yamlURL: yamlURL, codeURL: folderURL).generate()
    }
}
