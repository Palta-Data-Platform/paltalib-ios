//
//  BatchEventTemplate.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 10/08/2022.
//

import Foundation

struct BatchEventTemplate: Template {
    var filename: String {
        "BatchEvent"
    }
    
    var imports: [String] {
        [
            "Foundation",
            "PaltaLibAnalyticsModel",
            "PaltaAnlyticsTransport"
        ]
    }
    
    var statements: [Statement] {
        [
            eventCommonExtension,
            eventExtension,
            eventTypeExtension,
            eventPayloadExtension
        ]
    }
    
    private var eventCommonExtension: Statement {
        Extension(
            type: "PaltaLibAnalyticsModel.EventCommon",
            conformances: [],
            statements: [eventCommonMessage]
        )
    }
    
    private var eventCommonMessage: Statement {
        Property(
            visibility: .internal,
            name: "message",
            isMutable: true,
            returnType: "PaltaAnlyticsTransport.EventCommon",
            getter: Getter(
                statements: [
                    "var msg = PaltaAnlyticsTransport.EventCommon()",
                    "msg.eventType = eventType.intValue",
                    "msg.eventTs = Int64(timestamp)",
                    "msg.sessionID = Int64(sessionId)",
                    "return msg"
                ]
            )
        )
    }
    
    private var eventExtension: Statement {
        Extension(
            type: "PaltaAnlyticsTransport.Event",
            conformances: ["BatchEvent"],
            statements: [
                timestamp,
                dataInit,
                partsInit,
                serialize
            ]
        )
    }
    
    private var timestamp: Statement {
        Property(
            visibility: .public,
            name: "timestamp",
            isMutable: true,
            returnType: ReturnType(type: Int.self),
            getter: Getter(statements: ["Int(common.eventTs)"])
        )
    }
    
    private var partsInit: Statement {
        Init(
            visibility: .public,
            arguments: [
                .init(label: "common", type: "PaltaLibAnalyticsModel.EventCommon"),
                .init(label: "header", type: ReturnType(name: "PaltaLibAnalyticsModel.EventHeader", isOptional: true)),
                .init(label: "payload", type: "PaltaLibAnalyticsModel.EventPayload")
            ],
            statements: [
                "self.init()\n",
                Guard(
                    conditions: [
                        .cast("payload", "PaltaAnlyticsTransport.EventPayload")
                    ],
                    elseStatements: [
                        "assertionFailure(\"Mixing up different protobufs\")",
                        "return"
                    ]
                ),
                If(
                    conditions: [.cast("header", "EventHeader")],
                 statements: ["self.header = header.message"]
                ),
                "self.common = common.message",
                "self.payload = payload"
            ]
        )
    }
    
    private var dataInit: Statement {
        Init(
            visibility: .public,
            throws: true,
            arguments: [.init(label: "data", type: ReturnType(type: Data.self))],
            statements: ["try self.init(serializedData: data)"]
        )
    }
    
    private var serialize: Statement {
        Method(
            visibility: .public,
            throws: true,
            name: "serialize",
            statements: ["try serializedData()"],
            returnValue: ReturnType(type: Data.self)
        )
    }
    
    private var eventTypeExtension: Statement {
        Extension(
            type: "Int",
            conformances: ["EventType"],
            statements: [
                Property(
                    visibility: .public,
                    name: "intValue",
                    isMutable: true,
                    returnType: ReturnType(type: Int64.self),
                    getter: Getter(statements: ["Int64(self)"])
                )
            ]
        )
    }
    
    private var eventPayloadExtension: Statement {
        Extension(
            type: "PaltaAnlyticsTransport.EventPayload",
            conformances: ["PaltaLibAnalyticsModel.EventPayload"],
            statements: []
        )
    }
}
