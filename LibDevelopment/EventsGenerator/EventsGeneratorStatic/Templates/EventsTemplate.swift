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
        events.map { $0.statement }
    }
}
