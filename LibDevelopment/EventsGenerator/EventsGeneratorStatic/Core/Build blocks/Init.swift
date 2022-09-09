//
//  Init.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

struct Init {
    struct Argument {
        let label: String
        let type: ReturnType
        let defaultValue: String?
        
        init(label: String, type: ReturnType, defaultValue: String? = nil) {
            self.label = label
            self.type = type
            self.defaultValue = defaultValue
        }
    }
    let visibility: Visibility
    let isConvenience: Bool
    let isOverride: Bool
    let isRequired: Bool
    let `throws`: Bool
    let arguments: [Argument]
    
    let statements: [Statement]
    
    init(
        visibility: Visibility,
        isConvenience: Bool = false,
        isOverride: Bool = false,
        isRequired: Bool = false,
        throws: Bool = false,
        arguments: [Argument] = [],
        statements: [Statement] = []
    ) {
        self.visibility = visibility
        self.isConvenience = isConvenience
        self.isOverride = isOverride
        self.isRequired = isRequired
        self.throws = `throws`
        self.arguments = arguments
        self.statements = statements
    }
}

extension Init {
    static let `public` = Init(visibility: .public)
    static let `private` = Init(visibility: .private)
}

extension Init: Scope {
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
            isConvenience ? "convenience" : nil,
            isRequired ? "required" : nil,
            "init"
        ]
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
    private var afterParams: String {
        `throws` ? " throws" : ""
    }
    
    private var params: String {
        let manyArguments = arguments.count > 3
        let delimiter = manyArguments ? ",\n" : ", "
        
        var result = arguments
            .map { "\($0.label): \($0.type.stringValue)\($0.defaultValue.map { " = \($0)" } ?? "")" }
            .joined(separator: delimiter)
        
        if manyArguments {
            result.insert("\n", at: result.startIndex)
            result.append("\n")
        }
        
        return result
    }
}
