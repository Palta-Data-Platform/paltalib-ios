//
//  UserDefaults+Codable.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 08.04.2022.
//

import Foundation

public extension UserDefaults {
    func object<T: Decodable>(for key: String) -> T? {
        data(forKey: key).flatMap { try? JSONDecoder().decode(T.self, from: $0) }
    }

    func set<T: Encodable>(_ object: T?, for key: String) {
        set(try? JSONEncoder().encode(object), forKey: key)
    }
}
