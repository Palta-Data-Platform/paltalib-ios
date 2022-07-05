//
//  EventHeaderTemplate.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation

struct EventHeaderTemplate: Equatable {
    let elements: [SubEntityTemplate]
}

extension EventHeaderTemplate: Template {
    var filename: String {
        "EventHeader"
    }
    
    var imports: [String] {
        ["Foundation", "PaltaAnlyticsTransport", "PaltaLibAnalytics"]
    }
    
    var statements: [Statement] {
        [baseStruct, subentitiesExtension]
    }
}

extension EventHeaderTemplate {
    private var subentitiesExtension: Scope {
        Extension(
            type: "Header",
            statements: elements.map { $0.makeStruct() }
        )
    }
    
    private var baseStruct: Struct {
        Struct(
            visibility: .public,
            name: "Header",
            conformances: ["PaltaLibAnalytics.EventHeader"],
            properties: contextProperties + [messageProperty],
            inits: inits,
            methods: methods
        )
    }
    
    private var inits: [Init] {
        let emptyInitStatements = elements.map {
            "\($0.swiftEntityName.startLowercase) = \($0.swiftEntityName)()"
        }
        
        let dataInitStatements = [
            "let proto = try PaltaAnlyticsTransport.EventHeader(serializedData: data)"
        ]
        + elements.map {
            "\($0.swiftEntityName.startLowercase) = \($0.swiftEntityName)(message: proto.\($0.swiftEntityName.startLowercase.camelCaseToSnakeCase))"
        }
        
        return [
            Init(
                visibility: .public,
                arguments: [],
                statements: emptyInitStatements
            ),
            
            Init(
                visibility: .public,
                arguments: [("data", ReturnType(type: Data.self))],
                statements: dataInitStatements
            ),
        ]
    }
    
    private var methods: [Method] {
        [
            Method(
                visibility: .public,
                throws: true,
                name: "serialize",
                statements: ["try message.serializedData()"],
                returnValue: ReturnType(type: Data.self)
            )
        ]
    }
    
    private var messageProperty: Property {
        let messageInnerStatements = elements.map {
            "$0.\($0.swiftEntityName.startLowercase) = \($0.swiftEntityName.startLowercase).message"
        }
        
        let messageGetterStatement = BaseScope(
            prefix: "PaltaAnlyticsTransport.Context.with",
            suffix: nil,
            statements: messageInnerStatements
        )
        
        return Property(
            visibility: .internal,
            name: "message",
            isMutable: true,
            returnType: ReturnType(name: "Context"),
            getter: Getter(statements: [messageGetterStatement])
        )
    }
    
    private var contextProperties: [Property] {
        elements.map {
            Property(
                visibility: .public,
                name: $0.swiftEntityName.startLowercase,
                isMutable: true,
                returnType: ReturnType(name: $0.swiftEntityName)
            )
        }
    }
}

