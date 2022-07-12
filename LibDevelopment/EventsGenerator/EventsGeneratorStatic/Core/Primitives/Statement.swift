//
//  Statement.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

protocol Statement {
    func stringValue(for identLevel: Int) -> String
}

extension String: Statement {
    func stringValue(for identLevel: Int) -> String {
        identSpaces(level: identLevel) + self
    }
}
