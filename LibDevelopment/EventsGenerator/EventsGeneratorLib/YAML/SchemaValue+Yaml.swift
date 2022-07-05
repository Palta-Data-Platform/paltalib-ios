//
//  SchemaValue+Yaml.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation
import Yaml

extension SchemaValue {
    init(yaml: Yaml, skipRepeatedCheck: Bool = false) throws {
        guard case .dictionary(let dict) = yaml, case .string(let type) = dict[.string("type")] else {
            throw YAMLParser.Error.invalidStructure
        }
        
        print(dict)
        
        if case .bool(let isRepeated) = dict[.string("is_repeated")], isRepeated, !skipRepeatedCheck {
            self = try .array(SchemaValue(yaml: yaml, skipRepeatedCheck: true))
            return
        }

        switch type {
        case "string":
            self = .string
            
        case "timestamp":
            self = .timestamp
            
        case "boolean":
            self = .bool
            
        case "decimal":
            self = .decimal
            
        case "integer":
            self = .integer
            
        case "enum":
            self = try .getEnum(from: dict)
            
        default:
            throw YAMLParser.Error.invalidStructure
        }
    }
    
    private static func getEnum(from dict: [Yaml: Yaml]) throws -> SchemaValue {
        guard case .string(let name) = dict[.string("name")] else {
            throw YAMLParser.Error.invalidStructure
        }
        
        return .enum(name)
    }
}
