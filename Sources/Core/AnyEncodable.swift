//
//  AnyEncodable.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation

public struct AnyEncodable: Encodable {
    private let box: AnyEncodableBoxProtocol

    public init<T: Encodable>(_ value: T) {
        box = AnyEncodableBox(value: value)
    }

    public func encode(to encoder: Encoder) throws {
        try box.encode(to: encoder)
    }
}

public extension Encodable {
    var typeErased: AnyEncodable {
        AnyEncodable(self)
    }
}

private protocol AnyEncodableBoxProtocol {
    func encode(to encoder: Encoder) throws
}

private struct AnyEncodableBox<T: Encodable>: AnyEncodableBoxProtocol {
    let value: T

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
