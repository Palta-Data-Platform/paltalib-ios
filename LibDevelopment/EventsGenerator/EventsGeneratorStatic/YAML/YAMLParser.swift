//
//  YAMLParser.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
import Yaml

final class YAMLParser {
    enum Error: Swift.Error {
        case fileReadError
        case cantParse
        case invalidStructure
    }
    
    func convertYamlToTemplates(at url: URL) throws -> [Template] {
        let yaml = try parseYAML(at: url)
        
        return [
            try ContextTemplateBuilder(yaml: yaml[.string("context")]).contextTemplate(),
            try EventHeaderTemplateBuilder(yaml: yaml[.string("header")]).eventHeader(),
            try EnumsTemplateBuilder(yaml: yaml[.string("enum")]).enums(),
            try EventsTemplateBuilder(yaml: yaml[.string("event")]).eventsTemplate(),
            // Static templates
            BatchTemplate(),
            BatchCommonTemplate(),
            BatchEventTemplate(),
            ContextHelperTemplate(),
            StackTemplate()
        ]
    }
    
    private func parseYAML(at url: URL) throws -> [Yaml: Yaml] {
        let string: String
        
        do {
            string = try String(contentsOf: url)
        } catch {
            throw Error.fileReadError
        }
        
        let yaml: Yaml
        
        do {
            yaml = try Yaml.load(string)
        } catch {
            throw Error.cantParse
        }
        
        guard case .dictionary(let content) = yaml else {
            throw Error.invalidStructure
        }

        return content
    }
}
