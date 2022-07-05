//
//  Extension.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation

struct Extension {
    let type: String
    let statements: [Statement]
}

extension Extension: Scope {
    var prefix: String? {
        "extension \(type)"
    }
    
    var suffix: String? {
        nil
    }
}
