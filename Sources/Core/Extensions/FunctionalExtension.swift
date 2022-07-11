//
//  FunctionalExtension.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 21.04.2022.
//

import Foundation

public protocol FunctionalExtension {}

public extension FunctionalExtension {
    func `do`(_ sideEffect: (Self) -> Void) -> Self {
        sideEffect(self)
        return self
    }
}

extension NSObject: FunctionalExtension {}

extension JSONEncoder: FunctionalExtension {}
