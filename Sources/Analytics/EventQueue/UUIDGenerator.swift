//
//  UUIDGenerator.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation

protocol UUIDGenerator {
    func generateUUID() -> UUID
}

final class UUIDGeneratorImpl: UUIDGenerator {
    func generateUUID() -> UUID {
        UUID()
    }
}
