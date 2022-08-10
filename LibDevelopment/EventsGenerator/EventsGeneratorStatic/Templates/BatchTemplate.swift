//
//  BatchTemplate.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 10/08/2022.
//

import Foundation

struct BatchTemplate: Template {
    var filename: String {
        "Batch"
    }
    
    var imports: [String] {
        [
            "Foundation",
            "PaltaLibAnalyticsModel",
            "PaltaAnlyticsTransport"
        ]
    }
    
    var statements: [Statement] {
        [batchExtension]
    }
    
    private var batchExtension: Statement {
        Extension(
            type: "PaltaAnlyticsTransport.Batch",
            conformances: ["PaltaLibAnalyticsModel.Batch"],
            statements: [
                eventsInit,
                dataInit,
                serialize
            ]
        )
    }
    
    private var eventsInit: Statement {
        Init(
            visibility: .public,
            arguments: [
                .init(label: "common", type: "PaltaLibAnalyticsModel.BatchCommon"),
                .init(label: "context", type: "PaltaLibAnalyticsModel.BatchContext"),
                .init(label: "events", type: "[BatchEvent]")
            ],
            statements: [
                "self.init()",
                Guard(
                    conditions: [
                        .cast("common", "PaltaAnlyticsTransport.BatchCommon"),
                        .statement("let context = (context as? Context)?.message"),
                        .cast("events", "[PaltaAnlyticsTransport.Event]")
                    ],
                    elseStatements: [
                        "assertionFailure()",
                        "return"
                    ]
                ),
                "self.common = common",
                "self.context = context",
                "self.events = events"
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
}
