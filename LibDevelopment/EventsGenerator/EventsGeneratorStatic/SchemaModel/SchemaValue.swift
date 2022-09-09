//
//  SchemaValue.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 04/07/2022.
//

import Foundation

indirect enum SchemaValue: Equatable {
    case bool
    case decimal
    case `enum`(String)
    case integer
    case string
    case timestamp
    case array(SchemaValue)
}

extension SchemaValue {
    var type: ReturnType {
        switch self {
        case .bool:
            return ReturnType(type: Bool.self)
        case .decimal:
            return ReturnType(name: "Decimal")
        case .enum(let enumName):
            return ReturnType(name: enumName)
        case .integer:
            return ReturnType(type: Int.self)
        case .string:
            return ReturnType(type: String.self)
        case .timestamp:
            return ReturnType(type: Int.self)
        case .array(let element):
            return ReturnType(name: "[\(element.type.stringValue)]")
        }
    }
    
    var defaultValue: String {
        switch self {
        case .bool:
            return "false"
        case .decimal:
            return "0"
        case .enum(let name):
            return "\(name)(rawValue: 0)"
        case .integer:
            return "0"
        case .string:
            return "\"\""
        case .timestamp:
            return "0"
        case .array:
            return "[]"
        }
    }
    
    func converterToProto(_ varName: String) -> String {
        switch self {
        case .bool, .string:
            return varName
        case .decimal:
            return "String(describing: \(varName))"
        case .enum:
            return "\(varName).rawValue"
        case .integer, .timestamp:
            return "Int64(\(varName))"
        case .array(let element):
            return "\(varName).map { \(element.converterToProto("$0")) }"
        }
    }
}
