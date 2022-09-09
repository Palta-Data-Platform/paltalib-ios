//
//  ContextHelperTemplate.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 10/08/2022.
//

import Foundation

struct ContextHelperTemplate: Template {
    var filename: String {
        "ContextHelper"
    }
    
    var imports: [String] {
        ["PaltaLibAnalytics"]
    }
    
    var statements: [Statement] {
        [analyticsExtension]
    }
    
    private var analyticsExtension: Statement {
        Extension(
            type: "PaltaAnalytics",
            conformances: [],
            statements: [
                Method(
                    visibility: .public,
                    name: "editContext",
                    arguments: [
                        .init(
                            label: "_",
                            name: "editor",
                            type: "(inout Context) -> Void"
                        )
                    ],
                    statements: ["_editContext(editor)"]
                )
            ]
        )
    }
}
