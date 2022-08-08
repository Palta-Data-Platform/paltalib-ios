//
//  If.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 08/08/2022.
//

import Foundation

struct If {
    enum Condition {
        case unwrap(String)
        case equality(String, String)
        case statement(Statement)
    }
    
    let conditions: [Condition]
    let statements: [Statement]
}

extension If: Scope {
    var prefix: String? {
        "if " + conditions.map { $0.stringValue }.joined(separator: ", ")
    }
}

extension If.Condition {
    var stringValue: String {
        switch self {
        case .unwrap(let name):
            return "let \(name) = \(name)"
            
        case .equality(let valA, let valB):
            return "\(valA) == \(valB)"
            
        case .statement(let statement):
            return statement.stringValue(for: 0).trimmingCharacters(in: .newlines)
        }
    }
}
