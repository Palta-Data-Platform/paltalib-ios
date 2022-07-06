//
//  Struct.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

struct Struct {
    let visibility: Visibility
    let name: String
    let conformances: [String]
    let aliases: [Typealias]
    let properties: [Property]
    let inits: [Init]
    let methods: [Method]
    
    init(
        visibility: Visibility,
        name: String,
        conformances: [String] = [],
        aliases: [Typealias] = [],
        properties: [Property] = [],
        inits: [Init] = [],
        methods: [Method] = []
    ) {
        self.visibility = visibility
        self.name = name
        self.conformances = conformances
        self.aliases = aliases
        self.properties = properties
        self.inits = inits
        self.methods = methods
    }
}

extension Struct: Scope {
    var prefix: String? {
        "\(visibility) struct \(name)\(conformancesString)"
    }
    
    var suffix: String? {
        nil
    }
    
    var statements: [Statement] {
        properties.sorted(by: { $0.visibility.order < $1.visibility.order })
        + inits
        + methods.sorted(by: { $0.visibility.order < $1.visibility.order })
    }
    
    private var conformancesString: String {
        guard !conformances.isEmpty else {
            return ""
        }
        
        return ": \(conformances.joined(separator: ", "))"
    }
}
