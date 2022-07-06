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
    var statement: Statement {
        Enum(
            visibility: .public,
            name: name,
            rawType: "UInt64",
            cases: cases.map { .init(name: $0.name, rawValue: "\($0.id)") }
        )
    }
}
