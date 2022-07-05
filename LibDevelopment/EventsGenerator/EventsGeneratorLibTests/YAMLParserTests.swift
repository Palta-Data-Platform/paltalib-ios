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
        let exampleTemplate = ContextTemplate(elements: [
            .init(
                entityName: "Application",
                properties: [
                    ("app_id", .string),
                    ("app_platform", .string),
                    ("app_version", .string)
                ]
            ),
            
                .init(
                    entityName: "Appsflyer",
                    properties: [
                        ("appsflyer_id", .string),
                        ("appsflyer_media_source", .string)
                    ]
                ),
            
                .init(
                    entityName: "Device",
                    properties: [
                        ("device_brand", .string),
                        ("device_carrier", .string),
                        ("device_model", .string)
                    ]
                ),
            
                .init(
                    entityName: "Identify",
                    properties: [
                        ("gaid", .string),
                        ("idfa", .string),
                        ("idfv", .string)
                    ]
                ),
            
                .init(
                    entityName: "Os",
                    properties: [
                        ("os_name", .string),
                        ("os_version", .string)
                    ]
                ),
            
                .init(
                    entityName: "User",
                    properties: [
                        ("user_id", .string)
                    ]
                )
        ])
        
        let actualTemplate = try readTemplate(of: ContextTemplate.self)
        
        XCTAssertEqual(actualTemplate, exampleTemplate)
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
