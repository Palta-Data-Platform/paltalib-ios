//
//  Extension.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation

struct Extension {
    let type: String
    let conformances: [String]
    let statements: [Statement]
}

extension Extension: Scope {
    var prefix: String? {
        "extension \(type)\(conformancesString)"
    }
    
    var suffix: String? {
        nil
    }
    
    private var conformancesString: String {
        guard !conformances.isEmpty else {
            return ""
        }
        
        return ": \(conformances.joined(separator: ", "))"
    }
}
