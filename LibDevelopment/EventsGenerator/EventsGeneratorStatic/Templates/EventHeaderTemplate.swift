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
        ["Foundation", "PaltaAnlyticsTransport", "PaltaLibAnalyticsModel"]
    }
    
    var statements: [Statement] {
        [baseStruct, subentitiesExtension]
    }
}

extension EventHeaderTemplate {
    private var subentitiesExtension: Scope {
        Extension(
            type: "EventHeader",
            conformances: [],
            statements: elements.map { $0.makeStruct() }
        )
    }
    
    private var baseStruct: Struct {
        Struct(
            visibility: .public,
            name: "EventHeader",
            conformances: ["PaltaLibAnalyticsModel.EventHeader"],
            properties: contextProperties + [messageProperty],
            inits: inits,
            methods: methods
        )
    }
    
    private var inits: [Init] {
        let emptyInitStatements = elements.map {
            "\($0.swiftEntityName.startLowercase) = \($0.swiftEntityName)()"
        }
        
        let dataInitStatements = !elements.isEmpty
        ? [
            "let proto = try PaltaAnlyticsTransport.EventHeader(serializedData: data)"
        ]
        + elements.map {
            "\($0.swiftEntityName.startLowercase) = \($0.swiftEntityName)(message: proto.\($0.swiftEntityName.startLowercase))"
        }
        : []
        
        return [
            Init(
                visibility: .public,
                arguments: [],
                statements: emptyInitStatements
            ),
            
            Init(
                visibility: .public,
                throws: true,
                arguments: [Init.Argument(label: "data", type: ReturnType(type: Data.self))],
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
            prefix: "PaltaAnlyticsTransport.EventHeader.with",
            postBrace: elements.isEmpty ? " _ in" : nil,
            suffix: nil,
            statements: messageInnerStatements
        )
        
        return Property(
            visibility: .internal,
            name: "message",
            isMutable: true,
            returnType: ReturnType(name: "PaltaAnlyticsTransport.EventHeader"),
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

