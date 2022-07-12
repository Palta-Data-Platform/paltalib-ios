//
//  Method.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

struct Method {
    struct Argument {
        let label: String?
        let name: String
        let type: ReturnType
        let defaultValue: String?
        
        init(label: String? = nil, name: String, type: ReturnType, defaultValue: String? = nil) {
            self.label = label
            self.name = name
            self.type = type
            self.defaultValue = defaultValue
        }
    }
    
    let visibility: Visibility
    let isOverride: Bool
    let `throws`: Bool
    let name: String
    let arguments: [Argument]
    let statements: [Statement]
    let returnValue: ReturnType?
    
    init(
        visibility: Visibility,
        isOverride: Bool = false,
        throws: Bool = false,
        name: String,
        arguments: [Method.Argument] = [],
        statements: [Statement] = [],
        returnValue: ReturnType? = nil
    ) {
        self.visibility = visibility
        self.isOverride = isOverride
        self.throws = `throws`
        self.name = name
        self.arguments = arguments
        self.statements = statements
        self.returnValue = returnValue
    }
}

extension Method.Argument {
    var stringValue: String {
        "\(label.map { "\($0) " } ?? "")\(name): \(type.stringValue)\(defaultValue.map { " = \($0)" } ?? "")"
    }
}

extension Method: Scope {
    var prefix: String? {
        "\(beforeParams)(\(params))\(afterParams)"
    }
    
    var suffix: String? {
        nil
    }
    
    private var beforeParams: String {
        [
            "\(visibility)",
            isOverride ? "override" : nil,
            "func",
            name
        ]
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
    private var afterParams: String {
        [
            `throws` ? " throws" : nil,
            returnValue.map { " -> \($0.stringValue)" }
        ]
            .compactMap { $0 }
            .joined()
    }
    
    private var params: String {
        arguments
            .map { $0.stringValue }
            .joined(separator: ", ")
    }
}
