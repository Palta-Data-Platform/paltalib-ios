//
//  JSONDecoder.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

public extension JSONDecoder {
    static let `default` = JSONDecoder().do {
        $0.dateDecodingStrategy = .formatted(DateFormatter("YYYY-MM-dd'T'HH:mm:ss.SSS'Z'"))
    }
}

extension JSONDecoder: FunctionalExtension {}
