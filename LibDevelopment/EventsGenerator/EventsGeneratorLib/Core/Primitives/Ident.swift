//
//  Ident.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

private let spacesPerIdent = 4

func identSpaces(level: Int) -> String {
    String(repeating: " ", count: level * spacesPerIdent)
}
