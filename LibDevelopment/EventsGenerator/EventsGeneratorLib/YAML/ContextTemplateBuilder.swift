//
//  ContextTemplateBuilder.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
import Yaml

struct ContextTemplateBuilder {
    let yaml: Yaml?
    
    func contextTemplate() throws -> ContextTemplate {
        guard
            let yaml = yaml,
            case .dictionary(let elements) = yaml
        else {
            throw YAMLParser.Error.invalidStructure
        }
        
        let elementTemplates: [SubEntityTemplate] = try elements
            .map { key, value in
                guard case .string(let name) = key, case .dictionary(let dict) = value else {
                    throw YAMLParser.Error.invalidStructure
                }
                
                return SubEntityTemplate(
                    protoPrefix: "Context",
                    entityName: name,
                    properties: try properties(from: dict["properties"])
                )
            }
            .sorted(by: {
                $0.entityName < $1.entityName
            })
        
        return ContextTemplate(elements: elementTemplates)
    }
    
    private func properties(from yaml: Yaml?) throws -> [(String, SchemaValue)] {
        guard
            let yaml = yaml,
            case .dictionary(let props) = yaml
        else {
            throw YAMLParser.Error.invalidStructure
        }
        
        return try props
            .map { key, value in
                let type = try SchemaValue(yaml: value)
                
                guard case .string(let name) = key else {
                    throw YAMLParser.Error.invalidStructure
                }
                
                return (name.snakeCaseToCamelCase, type)
            }
            .sorted(by: {
                $0.0 < $1.0
            })
    }
}
