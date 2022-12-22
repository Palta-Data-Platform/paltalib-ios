//
//  NullRepresentable.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 22/12/2022.
//

import Foundation

protocol NullRepresentable {
    var asNull: NSNull? { get }
}

extension NSNull: NullRepresentable {
    var asNull: NSNull? {
        self
    }
}

extension Optional: NullRepresentable {
    var asNull: NSNull? {
        if case .none = self {
            return NSNull()
        } else {
            return nil
        }
    }
}
