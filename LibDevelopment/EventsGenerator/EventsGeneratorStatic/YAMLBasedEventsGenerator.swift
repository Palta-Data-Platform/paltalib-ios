//
//  YAMLBasedEventsGenerator.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation

public final class YAMLBasedEventsGenerator {
    private let yamlURL: URL
    private let codeURL: URL
    
    public init(yamlURL: URL, codeURL: URL) {
        self.yamlURL = yamlURL
        self.codeURL = codeURL
    }
    
    public func generate() throws {
        let templates = try YAMLParser().convertYamlToTemplates(at: yamlURL)
        
        try templates.forEach {
            try TemplateGenerator(template: $0, folderURL: codeURL).generate()
        }
    }
}
