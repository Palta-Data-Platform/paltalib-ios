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
                    ("appId", .string),
                    ("appPlatform", .string),
                    ("appVersion", .string)
                ]
            ),
            
                .init(
                    entityName: "Appsflyer",
                    properties: [
                        ("appsflyerId", .string),
                        ("appsflyerMediaSource", .string)
                    ]
                ),
            
                .init(
                    entityName: "Device",
                    properties: [
                        ("deviceBrand", .string),
                        ("deviceCarrier", .string),
                        ("deviceModel", .string)
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
                        ("osName", .string),
                        ("osVersion", .string)
                    ]
                ),
            
                .init(
                    entityName: "User",
                    properties: [
                        ("userId", .string)
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
