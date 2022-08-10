//
//  StackTemplate.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 10/08/2022.
//

import Foundation

struct StackTemplate: Template {
    var filename: String {
        "Stack"
    }
    
    var imports: [String] {
        [
            "PaltaLibAnalytics",
            "PaltaLibAnalyticsModel",
            "PaltaAnlyticsTransport"
        ]
    }
    
    var statements: [Statement] {
        [
            stackExtension,
            sessionStartExtension,
            "@objc(PBEventsWiring)",
            eventsWiring
        ]
    }
    
    private var stackExtension: Statement {
        Extension(
            type: "Stack",
            conformances: [],
            statements: [
                Property(
                    visibility: .public,
                    isStatic: true,
                    name: "`default`",
                    isMutable: false,
                    returnType: "Stack",
                    defaultValue: stackDefault
                )
            ]
        )
    }
    
    private var stackDefault: Statement {
        MultilineCall(
            call: "Stack",
            parameters: [
                "batchCommon: PaltaAnlyticsTransport.BatchCommon.self,",
                "context: Context.self,",
                "batch: PaltaAnlyticsTransport.Batch.self,",
                "event: PaltaAnlyticsTransport.Event.self,",
                "sessionStartEventType: 1,",
                "eventHeader: EventHeader.self,",
                "sessionStartEventPayloadProvider: { SessionStartEvent().payload }"
            ]
        )
    }
    
    private var sessionStartExtension: Statement {
        Extension(
            type: "EventPayloadSessionStart",
            conformances: ["PaltaLibAnalyticsModel.SessionStartEventPayload"],
            statements: []
        )
    }
    
    private var eventsWiring: Statement {
        Class(
            visibility: .private,
            name: "EventsWiring",
            inheritance: "NSObject",
            methods: [
                .init(
                    isObjc: true,
                    visibility: .private,
                    name: "wireStack",
                    statements: ["PaltaAnalytics.initiate(with: .default)"]
                )
            ]
        )
    }
}
