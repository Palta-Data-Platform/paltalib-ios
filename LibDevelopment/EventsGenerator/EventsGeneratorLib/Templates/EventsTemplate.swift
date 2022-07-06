//
//  EventsTemplate.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 06/07/2022.
//

import Foundation

struct EventsTemplate {
    let events: [SingleEventTemplate]
}

extension EventsTemplate: Template {
    var filename: String {
        "Events"
    }
    
    var imports: [String] {
        ["PaltaLibAnalytics", "PaltaAnlyticsTransport"]
    }
    
    var statements: [Statement] {
        conformanceDeclarations + events.map { $0.statement }
    }
}

extension EventsTemplate {
    private var conformanceDeclarations: [Statement] {
        [
            Extension(type: "Int", conformances: ["EventType"], statements: []),
            Extension(type: "PaltaAnlyticsTransport.EventPayload", conformances: ["PaltaLibAnalytics.EventPayload"], statements: [])
        ]
    }
}
