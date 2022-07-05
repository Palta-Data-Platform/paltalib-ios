//
//  ContextElementTemplate.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 04/07/2022.
//

import Foundation

struct ContextElementTemplate: Equatable {
    static func == (lhs: ContextElementTemplate, rhs: ContextElementTemplate) -> Bool {
        guard lhs.entityName == rhs.entityName, lhs.properties.count == rhs.properties.count else {
            return false
        }
        
        return lhs.properties.enumerated().allSatisfy { index, element in
            element.0 == rhs.properties[index].0 && element.1 == rhs.properties[index].1
        }
    }
    
    let entityName: String
    let properties: [(String, SchemaValue)]
}

extension ContextElementTemplate {
    var swiftEntityName: String {
        entityName
//        entityName.replacingOccurrences(of: "Context", with: "")
    }
    
    var protoEntityName: String {
        "Context" + entityName
    }
    
    func makeStruct() -> Struct {
        let initArguments = properties.map {
            ($0, $1.type)
        }
        
        let initStatementsAssign = properties
            .map {
                "message.\($0) = \($1.converterToProto($0))"
            }
        
        let initt = Init(
            visibility: .public,
            arguments: initArguments,
            statements: ["message = .init()"] + initStatementsAssign
        )
        
        return Struct(
            visibility: .public,
            name: swiftEntityName,
            properties: [
                Property(
                    visibility: .internal,
                    name: "message",
                    isMutable: true,
                    returnType: ReturnType(name: protoEntityName)
                )
            ],
            inits: [initt]
        )
    }
}
