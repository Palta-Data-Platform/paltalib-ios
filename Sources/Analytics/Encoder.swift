//
//  Encoder.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 22/03/2023.
//

import Foundation

extension JSONEncoder {
    static let `default`: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.description)
        }
        return encoder
    }()
}
