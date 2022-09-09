//
//  MultilineCall.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 10/08/2022.
//

import Foundation

struct MultilineCall {
    let call: String
    let parameters: [String]
}

extension MultilineCall: Statement {
    func stringValue(for identLevel: Int) -> String {
        identSpaces(level: identLevel) + call + "(" + "\n"
        + parameters.map { identSpaces(level: identLevel + 1) + $0 }.joined(separator: "\n") + "\n"
        + identSpaces(level: identLevel) + ")"
    }
}
