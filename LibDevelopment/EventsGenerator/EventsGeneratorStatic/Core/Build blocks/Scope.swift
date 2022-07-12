//
//  Scope.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

protocol Scope: Statement {
    var prefix: String? { get }
    var suffix: String? { get }
    var statements: [Statement] { get }
}

struct BaseScope: Scope {
    let prefix: String?
    let suffix: String?
    let statements: [Statement]
}

extension Scope {
    func stringValue(for identLevel: Int) -> String {
        var result = identSpaces(level: identLevel)
        
        if let prefix = multilineCheckedPrefix(for: identLevel) {
            result += "\(prefix) "
        }
        
        result += "{"
        
        for statement in statements {
            result += "\n\(statement.stringValue(for: identLevel + 1))"
            
            if statement is Scope, result.trimmingCharacters(in: .whitespaces).last != "\n" {
                result += "\n"
            }
        }
        
        if result.last == "\n" {
            result.removeLast()
        }
        
        result += "\n\(identSpaces(level: identLevel))}"
        
        if let suffix = `suffix` {
            result += " \(suffix)"
        }
        
        return result
    }
    
    private func multilineCheckedPrefix(for identLevel: Int) -> String? {
        guard let prefix = `prefix` else {
            return nil
        }
        
        var strings = prefix.components(separatedBy: "\n")
        
        guard strings.count > 2 else {
            return prefix
        }
        
        for i in 1..<(strings.count-1) {
            strings[i] = identSpaces(level: identLevel + 1) + strings[i]
        }
        
        strings[strings.endIndex - 1] = identSpaces(level: identLevel) + strings[strings.endIndex - 1]
        
        return strings.joined(separator: "\n")
    }
}
