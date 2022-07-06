//
//  YAMLParserTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
import XCTest
@testable import EventsGeneratorLib

final class YAMLParserTests: XCTestCase {
    func testContext() throws {
        let expectedTemplate = ContextTemplate(elements: [
            .init(
                protoPrefix: "Context",
                entityName: "Application",
                properties: [
                    ("app_id", .string),
                    ("app_platform", .string),
                    ("app_version", .string)
                ]
            ),
            
                .init(
                    protoPrefix: "Context",
                    entityName: "Appsflyer",
                    properties: [
                        ("appsflyer_id", .string),
                        ("appsflyer_media_source", .string)
                    ]
                ),
            
                .init(
                    protoPrefix: "Context",
                    entityName: "Device",
                    properties: [
                        ("device_brand", .string),
                        ("device_carrier", .string),
                        ("device_model", .string)
                    ]
                ),
            
                .init(
                    protoPrefix: "Context",
                    entityName: "Identify",
                    properties: [
                        ("gaid", .string),
                        ("idfa", .string),
                        ("idfv", .string)
                    ]
                ),
            
                .init(
                    protoPrefix: "Context",
                    entityName: "Os",
                    properties: [
                        ("os_name", .string),
                        ("os_version", .string)
                    ]
                ),
            
                .init(
                    protoPrefix: "Context",
                    entityName: "User",
                    properties: [
                        ("user_id", .string)
                    ]
                )
        ])
        
        let actualTemplate = try readTemplate(of: ContextTemplate.self)
        
        XCTAssertEqual(actualTemplate, expectedTemplate)
    }
    
    func testEventHeader() throws {
        let expectedTemplate = EventHeaderTemplate(
            elements: [
                .init(
                    protoPrefix: "EventHeader",
                    entityName: "Parent",
                    properties: [("parent_elements", .array(.string))]
                )
            ]
        )
        
        let actualTemplate = try readTemplate(of: EventHeaderTemplate.self)
        
        XCTAssertEqual(actualTemplate, expectedTemplate)
    }
    
    func testEnums() throws {
        let expectedTemplate = EnumsTemplate(
            enums: [
                .init(
                    name: "Result",
                    cases: [
                        .init(id: 1, name: "success"),
                        .init(id: 2, name: "skip"),
                        .init(id: 3, name: "error")
                    ]
                )
            ]
        )
        
        let actualTemplate = try readTemplate(of: EnumsTemplate.self)
        
        XCTAssertEqual(actualTemplate, expectedTemplate)
    }
    
    private func readTemplate<T: Template>(of type: T.Type) throws -> T? {
        let yamlURL = Bundle
            .init(
                for: StructTests.self
            )
            .url(
                forResource: "config",
                withExtension: "yaml",
                subdirectory: "Examples"
            )!
        
        let templates = try YAMLParser().convertYamlToTemplates(at: yamlURL)
        
        return templates.lazy.compactMap { $0 as? T }.first
    }
}
