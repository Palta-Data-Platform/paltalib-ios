//
//  SubEntityTemplate.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 04/07/2022.
//

import Foundation

struct SubEntityTemplate: Equatable {
    static func == (lhs: SubEntityTemplate, rhs: SubEntityTemplate) -> Bool {
        guard lhs.entityName == rhs.entityName,
              lhs.protoPrefix == rhs.protoPrefix,
                lhs.properties.count == rhs.properties.count else {
            return false
        }
        
        return lhs.properties.enumerated().allSatisfy { index, element in
            element.0 == rhs.properties[index].0 && element.1 == rhs.properties[index].1
        }
    }
    
    let protoPrefix: String
    let entityName: String
    let properties: [(String, SchemaValue)]
}

extension SubEntityTemplate {
    var swiftEntityName: String {
        entityName
    }
    
    var protoEntityName: String {
        protoPrefix + entityName
    }
    
    func makeStruct() -> Struct {
        let argumentProvider = ContextReservedFields()
        let initArguments = properties.map {
            argumentProvider.initArgument(for: $0, in: swiftEntityName)
        }
        
        let initStatementsAssign: [Statement] = zip(properties, initArguments)
            .map { (property, initArg) -> [Statement] in
                let (name, type) = property
                let assignment = "message.\(name.snakeCaseToCamelCase) = \(type.converterToProto(name.snakeCaseToCamelCase))"
                
                if initArg.type.isOptional {
                    return [
                        "\n",
                        If(
                            conditions: [.unwrap(name.snakeCaseToCamelCase)],
                            statements: [assignment]
                        )
                    ]
                } else {
                    return [assignment]
                }
            }
            .flatMap { $0 }
        
        let initWithArgs = Init(
            visibility: .public,
            arguments: initArguments,
            statements: ["message = .init()"] + initStatementsAssign
        )
        
        let initWithMsg = Init(
            visibility: .fileprivate,
            arguments: [.init(label: "message", type: ReturnType(name: protoEntityName))],
            statements: ["self.message = message"]
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
            inits: [initWithMsg, initWithArgs]
        )
    }
}
