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
    
    func testEvents() throws {
        let expectedTemplate = SingleEventTemplate(
            id: 6,
            name: "EdgeCase",
            properties: [
                .init(name: "prop_boolean", type: .bool),
                .init(name: "prop_boolean_array", type: .array(.bool)),
                .init(name: "prop_decimal_1", type: .decimal),
                .init(name: "prop_decimal_2", type: .decimal),
                .init(name: "prop_decimal_array", type: .array(.decimal)),
                .init(name: "prop_enum", type: .enum("Result")),
                .init(name: "prop_enum_array", type: .array(.enum("Result"))),
                .init(name: "prop_integer", type: .integer),
                .init(name: "prop_integer_array", type: .array(.integer)),
                .init(name: "prop_string", type: .string),
                .init(name: "prop_string_array", type: .array(.string)),
                .init(name: "prop_timestamp", type: .timestamp),
                .init(name: "prop_timestamp_array", type: .array(.timestamp))
            ]
        )
        
        let actualTemplate = try readTemplate(of: EventsTemplate.self)?.events.first(where: { $0.id == 6 })
        
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
