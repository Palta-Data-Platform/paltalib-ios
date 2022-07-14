//
//  SingleEventTemplate.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 06/07/2022.
//

import Foundation

struct SingleEventTemplate: Equatable {
    struct Prop: Equatable {
        let name: String
        let type: SchemaValue
    }
    
    let id: Int
    let name: String
    let properties: [Prop]
}

extension SingleEventTemplate {
    var statement: Statement {
        Struct(
            visibility: .public,
            name: "\(name)Event",
            conformances: ["PaltaLibAnalytics.Event"],
            aliases: aliases,
            properties: [headerProp, payloadProp, typeProp, payloadPrivateProp],
            inits: [initt]
        )
    }
    
    private var headerProp: Property {
        Property(visibility: .public, name: "header", returnType: ReturnType(name: "EventHeader"))
    }
    
    private var payloadProp: Property {
        let getter = Getter(statements: [
            BaseScope(
                prefix: "PaltaAnlyticsTransport.EventPayload.with",
                postBrace: nil,
                suffix: nil,
                statements: ["$0.event\(id) = _payload"]
            )
        ])
        
        return Property(
            visibility: .public,
            name: "payload",
            isMutable: true,
            returnType: ReturnType(name: "Payload"),
            getter: getter
        )
    }
    
    private var typeProp: Property {
        Property(
            visibility: .public,
            name: "type",
            isMutable: true,
            returnType: ReturnType(name: "EventType"),
            getter: Getter(statements: ["\(id)"])
        )
    }
    
    private var payloadPrivateProp: Property {
        Property(visibility: .private, name: "_payload", returnType: ReturnType(name: "EventPayload\(name)"))
    }
    
    private var initt: Init {
        let arguments = [
            Init.Argument(label: "header", type: ReturnType(name: "EventHeader"), defaultValue: ".init()")
        ]
        + properties.map {
            Init.Argument(
                label: $0.name.snakeCaseToCamelCase,
                type: $0.type.type,
                defaultValue: $0.type.defaultValue
            )
        }
                          
        let statements: [Statement] = [
            "self.header = header",
            BaseScope(
                prefix: "self._payload = EventPayload\(name).with",
                postBrace: properties.isEmpty ? " _ in" : nil,
                suffix: nil,
                statements: properties.map {
                    "$0.\($0.name.snakeCaseToCamelCase) = \($0.type.converterToProto($0.name.startLowercase.snakeCaseToCamelCase))"
                }
            )
        ]
        
        return Init(
            visibility: .public,
            arguments: arguments,
            statements: statements
        )
    }
    
    private var aliases: [Typealias] {
        [
            .init(
                visibility: .public,
                firstType: "Header",
                secondType: ReturnType(name: "PaltaEvents.EventHeader")
            ),
            .init(
                visibility: .public,
                firstType: "Payload",
                secondType: ReturnType(name: "PaltaAnlyticsTransport.EventPayload")
            ),
            .init(
                visibility: .public,
                firstType: "EventType",
                secondType: ReturnType(type: Int.self)
            )
        ]
    }
}
