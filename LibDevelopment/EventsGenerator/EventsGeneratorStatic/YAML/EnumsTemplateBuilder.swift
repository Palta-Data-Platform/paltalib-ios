//
//  EnumsTemplateBuilder.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
import Yaml

struct EnumsTemplateBuilder {
    let yaml: Yaml?
    
    func enums() throws -> EnumsTemplate {
        guard
            let yaml = yaml,
            case .dictionary(let enums) = yaml
        else {
            throw YAMLParser.Error.invalidStructure
        }
        
        let elementTemplates: [SingleEnumTemplate] = try enums
            .map {
                try enumm(from: $0.value, key: $0.key)
            }
            .sorted(by: {
                $0.name < $1.name
            })
        
        return EnumsTemplate(enums: elementTemplates)
    }
    
    private func enumm(from yaml: Yaml?, key: Yaml) throws -> SingleEnumTemplate {
        guard
            let yaml = yaml,
            case .dictionary(let dict) = yaml,
            case .string(let name) = key,
            case .dictionary(let values) = dict["values"]
        else {
            throw YAMLParser.Error.invalidStructure
        }
        
        let prefix = "\(name.uppercased())_"
        let cases = try values
            .map { try casee(from: $0.value, and: $0.key, removingPrefix: prefix) }
            .sorted(by: { $0.id < $1.id })
        
        return .init(
            name: name,
            cases: cases
        )
    }
    
    private func casee(from yaml: Yaml?, and key: Yaml, removingPrefix: String) throws -> SingleEnumTemplate.Case {
        guard
            let yaml = yaml,
            case .dictionary(let dict) = yaml,
            case .string(let name) = key,
            case .int(let id) = dict["id"]
        else {
            throw YAMLParser.Error.invalidStructure
        }
        
        return .init(
            id: id,
            name: name.replacingOccurrences(of: removingPrefix, with: "").lowercased().snakeCaseToCamelCase
        )
    }
}
