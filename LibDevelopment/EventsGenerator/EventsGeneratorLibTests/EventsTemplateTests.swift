//
//  EventsTemplateTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 06/07/2022.
//

import Foundation
import XCTest
@testable import EventsGeneratorStatic

final class EventsTemplateTests: GenerationTests {
    func testEvents() throws {
        let eventsTemplate = EventsTemplate(
            events: [
                .init(
                    id: 0,
                    name: "PageOpen",
                    properties: [
                        .init(name: "pageID", type: .string),
                        .init(name: "title", type: .string)
                    ]
                )
            ]
        )
        
        let generator = TemplateGenerator(template: eventsTemplate, folderURL: folderURL)
        try generator.generate()
        
        let generatedData = try Data(contentsOf: folderURL.appendingPathComponent("Events.swift"))
        let exampleData = try loadExampleData(with: "EventsExample")
        
        XCTAssertEqual(generatedData, exampleData)
    }
}
