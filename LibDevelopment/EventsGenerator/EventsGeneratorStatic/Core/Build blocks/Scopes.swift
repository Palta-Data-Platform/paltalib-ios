//
//  Scopes.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

struct Setter: Scope {
    var prefix: String? {
        "set"
    }
    
    var suffix: String? {
        nil
    }
    
    let statements: [Statement]
}

struct Getter: Scope {
    var prefix: String? {
        "get"
    }
    
    var suffix: String? {
        nil
    }
    
    let statements: [Statement]
}

struct DidSet: Scope {
    var prefix: String? {
        "didSet"
    }
    
    var suffix: String? {
        nil
    }
    
    let statements: [Statement]
}

struct WillSet: Scope {
    var prefix: String? {
        "willSet"
    }
    
    var suffix: String? {
        nil
    }
    
    let statements: [Statement]
}
