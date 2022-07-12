//
//  Enum.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

struct Enum {
    struct Case {
        struct NestedData {
            let label: String?
            let type: ReturnType
        }
        
        let name: String
        let rawValue: Statement?
        let nestedData: [NestedData]?
        
        init(name: String, rawValue: Statement? = nil, nestedData: [Enum.Case.NestedData]? = nil) {
            self.name = name
            self.rawValue = rawValue
            self.nestedData = nestedData
        }
    }
    
    let visibility: Visibility
    let name: String
    let conformances: [String]?
    let rawType: String?
    let cases: [Case]
    let inits: [Init]
    
    init(
        visibility: Visibility,
        name: String,
        conformances: [String]? = nil,
        rawType: String? = nil,
        cases: [Enum.Case],
        inits: [Init] = []
    ) {
        self.visibility = visibility
        self.name = name
        self.conformances = conformances
        self.rawType = rawType
        self.cases = cases
        self.inits = inits
    }
}

extension Enum.Case.NestedData {
    var stringValue: String {
        "\(label.map { "\($0): " } ?? "")\(type.stringValue)"
    }
}

extension Enum.Case: Statement {
    func stringValue(for identLevel: Int) -> String {
        var result = "\(identSpaces(level: identLevel))case \(name)"
        
        if let rawValue = rawValue {
            result += " = \(rawValue)"
        } else if let nestedData = nestedData {
            result += "(\(nestedData.map { $0.stringValue }.joined(separator: ", ")))"
        }
        
        return result
    }
}

extension Enum: Scope {
    var prefix: String? {
        "\(visibility) enum \(name)\(conformancesString)"
    }
    
    var suffix: String? {
        nil
    }
    
    var statements: [Statement] {
        cases + inits
    }
    
    private var conformancesString: String {
        let parts = [rawType].compactMap { $0 } + (conformances ?? [])
        
        guard !parts.isEmpty else {
            return ""
        }
        
        return ": \(parts.joined(separator: ", "))"
    }
}
