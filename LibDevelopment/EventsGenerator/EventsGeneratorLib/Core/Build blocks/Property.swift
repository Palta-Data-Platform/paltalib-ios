//
//  Property.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

struct Property {
    let visibility: Visibility
    let name: String
    let isMutable: Bool
    let returnType: ReturnType
    let setter: Setter?
    let getter: Getter?
    let didSet: DidSet?
    let willSet: WillSet?
    let defaultValue: Statement?
    
    init(
        visibility: Visibility,
        name: String,
        isMutable: Bool = false,
        returnType: ReturnType,
        setter: Setter? = nil,
        getter: Getter? = nil,
        didSet: DidSet? = nil,
        willSet: WillSet? = nil,
        defaultValue: Statement? = nil
    ) {
        self.visibility = visibility
        self.name = name
        self.isMutable = isMutable
        self.returnType = returnType
        self.setter = setter
        self.getter = getter
        self.didSet = didSet
        self.willSet = willSet
        self.defaultValue = defaultValue
    }
}

extension Property: Statement {
    func stringValue(for identLevel: Int) -> String {
        let inScopeStatements = self.inScopeStatements
        let firstString = "\(baseString)\(defaultValueString ?? "")"
        
        if inScopeStatements.isEmpty {
            return firstString.stringValue(for: identLevel) + "\n"
        } else {
            return BaseScope(
                prefix: firstString,
                suffix: "\n",
                statements: inScopeStatements
            ).stringValue(for: identLevel)
        }
    }
    
    private var varLet: String {
        isMutable ? "var" : "let"
    }
    
    private var baseString: String {
        "\(visibility) \(varLet) \(name): \(returnType.stringValue)"
    }
    
    private var defaultValueString: String? {
        defaultValue.map { " = \($0.stringValue(for: 0))" }
    }
    
    private var inScopeStatements: [Statement] {
        ([setter, getter, `willSet`, `didSet`] as [Statement?]).compactMap { $0 }
    }
}
