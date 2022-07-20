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
    private var sequenceNumber: UInt16 = 0
    
    private let lock = NSRecursiveLock()
    
    func generateUUID() -> UUID {
        lock.lock()
        let seq = sequenceNumber & 0x0FFF
        sequenceNumber = sequenceNumber.addingReportingOverflow(1).partialValue
        lock.unlock()
        
        var bytes: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        
        let timestampSeconds = currentTimestamp() / 1000
        let timestampMsec = (currentTimestamp() % 1000) & 0x0000000FFF
        
        // Implementing UUID v7 spec
        
        bytes.0 = UInt8(truncatingIfNeeded: timestampSeconds >> 28)
        bytes.1 = UInt8(truncatingIfNeeded: timestampSeconds >> 20)
        bytes.2 = UInt8(truncatingIfNeeded: timestampSeconds >> 12)
        bytes.3 = UInt8(truncatingIfNeeded: timestampSeconds >> 4)
        bytes.4 = UInt8(truncatingIfNeeded: (timestampSeconds << 4) | (timestampMsec >> 8))
        bytes.5 = UInt8(truncatingIfNeeded: timestampMsec)
        bytes.6 = UInt8(truncatingIfNeeded: 0x70 | seq >> 8)
        bytes.7 = UInt8(truncatingIfNeeded: seq)
        bytes.8 = 0x80 | (UInt8.random() & 0x3F)
        bytes.9 = .random()
        bytes.10 = .random()
        bytes.11 = .random()
        bytes.12 = .random()
        bytes.13 = .random()
        bytes.14 = .random()
        bytes.15 = .random()
        
        return UUID(uuid: bytes)
    }
}

private extension UInt8 {
    static func random() -> UInt8 {
        .random(in: UInt8.min...UInt8.max)
    }
}
