//
//  SingleEnumTemplate.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation

struct SingleEnumTemplate: Equatable {
    struct Case: Equatable {
        let id: Int
        let name: String
    }
    
    let name: String
    let cases: [Case]
}

extension SingleEnumTemplate {
    private var rawValueProp: Property {
        Property(
            visibility: .public,
            name: "rawValue",
            returnType: ReturnType(type: Int64.self)
        )
    }
    
    private var casesProps: [Property] {
        cases.map {
            Property(
                visibility: .public,
                isStatic: true,
                name: $0.name,
                returnType: ReturnType(name: name),
                defaultValue: "\(name)(rawValue: \($0.id))"
            )
        }
    }
    
    private var initt: Init {
        Init(
            visibility: .public,
            arguments: [Init.Argument(label: "rawValue", type: ReturnType(type: Int64.self))],
            statements: ["self.rawValue = rawValue"]
        )
    }
    
    var statement: Statement {
        Struct(
            visibility: .public,
            name: name,
            properties: casesProps + [rawValueProp],
            inits: [initt]
        )
    }
}
