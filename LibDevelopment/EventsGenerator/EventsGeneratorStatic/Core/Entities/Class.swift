//
//  Class.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

struct Class {
    let visibility: Visibility
    let name: String
    let isFinal: Bool
    let inheritance: String?
    let conformances: [String]?
    let properties: [Property]
    let inits: [Init]
    let methods: [Method]
    
    init(
        visibility: Visibility,
        name: String,
        isFinal: Bool = true,
        inheritance: String? = nil,
        conformances: [String]? = nil,
        properties: [Property] = [],
        inits: [Init] = [],
        methods: [Method] = []
    ) {
        self.visibility = visibility
        self.name = name
        self.isFinal = isFinal
        self.inheritance = inheritance
        self.conformances = conformances
        self.properties = properties
        self.inits = inits
        self.methods = methods
    }
}

extension Class: Scope {
    var prefix: String? {
        "\(visibility)\(finalString) class \(name)\(conformancesString)"
    }
    
    var suffix: String? {
        nil
    }
    
    var statements: [Statement] {
        properties.sorted(by: { $0.visibility.order < $1.visibility.order })
        + inits
        + methods
    }
    
    private var finalString: String {
        isFinal ? " final" : ""
    }
    
    private var conformancesString: String {
        let parts = [inheritance].compactMap { $0 } + (conformances ?? [])
        
        guard !parts.isEmpty else {
            return ""
        }
        
        return ": \(parts.joined(separator: ", "))"
    }
}
