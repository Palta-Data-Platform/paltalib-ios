//
//  ReturnType.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

struct ReturnType {
    let name: String
    let isOptional: Bool
    
    init(name: String, isOptional: Bool = false) {
        self.name = name
        self.isOptional = isOptional
    }
    
    init<T>(type: T.Type) {
        self.name = "\(T.self)"
        self.isOptional = false
    }
    
    func makeOptional() -> ReturnType {
        ReturnType(name: name, isOptional: true)
    }
}

extension ReturnType {
    var stringValue: String {
        "\(name)\(isOptional ? "?" : "")"
    }
}

extension ReturnType: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.init(name: value)
    }
}
