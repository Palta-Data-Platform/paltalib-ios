//
//  Typealias.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 06/07/2022.
//

import Foundation

struct Typealias {
    let visibility: Visibility
    let firstType: ReturnType
    let secondType: ReturnType
}

extension Typealias: Statement {
    func stringValue(for identLevel: Int) -> String {
        "\(visibility) typealias \(firstType.stringValue) = \(secondType.stringValue)".stringValue(for: identLevel)
    }
}
