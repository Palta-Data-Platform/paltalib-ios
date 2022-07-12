//
//  EnumsTemplate.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation

struct EnumsTemplate: Equatable {
    let enums: [SingleEnumTemplate]
}

extension EnumsTemplate: Template {
    var filename: String {
        "Enums"
    }
    
    var imports: [String] {
        ["Foundation"]
    }
    
    var statements: [Statement] {
        enums.map { $0.statement }
    }
}
