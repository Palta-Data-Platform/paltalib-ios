//
//  EventsTemplateBuilder.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 06/07/2022.
//

import Foundation
import Yaml

struct EventsTemplateBuilder {
    let yaml: Yaml?
    
    func eventsTemplate() throws -> EventsTemplate {
        guard
            let yaml = yaml,
            case .dictionary(let elements) = yaml
        else {
            throw YAMLParser.Error.invalidStructure
        }
        
        let individualEventTemplates: [SingleEventTemplate] = try elements
            .map { key, value in
                guard
                    case .string(let name) = key,
                    case .dictionary(let dict) = value,
                        case .int(let id) = dict[.string("id")]
                else {
                    throw YAMLParser.Error.invalidStructure
                }
                
                return SingleEventTemplate(
                    id: id,
                    name: name,
                    properties: try properties(from: dict["properties"])
                )
            }
            .sorted(by: {
                $0.name < $1.name
            })
        
        return EventsTemplate(events: individualEventTemplates)
    }
    
    private func properties(from yaml: Yaml?) throws -> [SingleEventTemplate.Prop] {
        guard let yaml = yaml else {
            return []
        }

        guard case .dictionary(let props) = yaml else {
            throw YAMLParser.Error.invalidStructure
        }
        
        return try props
            .map { key, value in
                let type = try SchemaValue(yaml: value)
                
                guard case .string(let name) = key else {
                    throw YAMLParser.Error.invalidStructure
                }
                
                return .init(name: name, type: type)
            }
            .sorted(by: {
                $0.name < $1.name
            })
    }
}

