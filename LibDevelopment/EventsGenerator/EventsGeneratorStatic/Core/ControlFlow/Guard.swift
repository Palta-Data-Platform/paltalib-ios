//
//  Guard.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 10/08/2022.
//

import Foundation

struct Guard {
    let conditions: [If.Condition]
    let elseStatements: [Statement]
}

extension Guard: Scope {
    var prefix: String? {
        let conditionsString = conditions.map { $0.stringValue }.joined(separator: ",\n")
        
        if conditions.count > 1 {
            return "guard\n\(conditionsString)\nelse"
        } else {
            return "guard \(conditionsString) else"
        }
        
    }
    
    var statements: [Statement] {
        elseStatements
    }
}
