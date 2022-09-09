//
//  UUIDGeneratorTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/07/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class UUIDGeneratorTests: XCTestCase {
    func testIdsSorted() {
        mockedTimestamp = nil
        let generator = UUIDGeneratorImpl()
        
        let uuids: [UUID] = (0...1000).map { _ in
            generator.generateUUID()
        }
        
        XCTAssertEqual(uuids, uuids.sorted())
    }
    
    func testRandom() {
        let generator = UUIDGeneratorImpl()
        
        let uuids: [UUID] = (0...100000).map { _ in
            generator.generateUUID()
        }
        
        XCTAssertEqual(uuids.count, Set(uuids).count)
    }
    
    func testTimestampSec() {
        mockedTimestamp = 3_556_354_535_502
        let bytes = UUIDGeneratorImpl().generateUUID().uuid
        
        XCTAssertEqual(bytes.0, 0x0D)
        XCTAssertEqual(bytes.1, 0x3F)
        XCTAssertEqual(bytes.2, 0x9A)
        XCTAssertEqual(bytes.3, 0x9E)
        XCTAssertEqual(bytes.4 & 0xF0, 0x70)
    }
    
    func testTimestampMsec() {
        mockedTimestamp = 3_556_354_535_502
        let bytes = UUIDGeneratorImpl().generateUUID().uuid
        
        XCTAssertEqual(bytes.4 & 0x0F, 0x01)
        XCTAssertEqual(bytes.5, 0xF6)
    }
    
    func testVer() {
        let generator = UUIDGeneratorImpl()
        
        let bytes = generator.generateUUID().uuid
        
        XCTAssertEqual(bytes.6 & 0xF0, 0x70)
    }
    
    func testSequence() {
        let generator = UUIDGeneratorImpl()
        
        for _ in 0...1000 {
            _ = generator.generateUUID()
        }
        
        let bytes1 = generator.generateUUID().uuid
        let bytes2 = generator.generateUUID().uuid
        
        XCTAssertEqual(bytes1.6 & 0x0F, 0x03)
        XCTAssertEqual(bytes2.6 & 0x0F, 0x03)
        XCTAssertEqual(bytes1.7, 0xE9)
        XCTAssertEqual(bytes2.7, 0xEA)
    }
    
    func testVar() {
        let generator = UUIDGeneratorImpl()
        
        let bytes = generator.generateUUID().uuid
        
        XCTAssertEqual(bytes.8 & 0xC0, 0x80)
    }
    
    func testConcurrentGeneration() {
        var seqNumbers: IndexSet = []
        let lock = NSRecursiveLock()
        let generator = UUIDGeneratorImpl()
        
        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            let bytes = generator.generateUUID().uuid
            let seq = (Int(bytes.6 & 0x0F) << 8) | Int(bytes.7)
            
            lock.lock()
            seqNumbers.insert(seq)
            lock.unlock()
        }
        
        XCTAssertEqual(seqNumbers, IndexSet(0...99))
    }
}

extension UUID: Comparable {
    public static func < (lhs: UUID, rhs: UUID) -> Bool {
        if lhs.uuid.0 != rhs.uuid.0 {
            return lhs.uuid.0 < rhs.uuid.0
        } else if lhs.uuid.1 != rhs.uuid.1 {
            return lhs.uuid.1 < rhs.uuid.1
        } else if lhs.uuid.2 != rhs.uuid.2 {
            return lhs.uuid.2 < rhs.uuid.2
        } else if lhs.uuid.3 != rhs.uuid.3 {
            return lhs.uuid.3 < rhs.uuid.3
        } else if lhs.uuid.4 != rhs.uuid.4 {
            return lhs.uuid.4 < rhs.uuid.4
        } else if lhs.uuid.5 != rhs.uuid.5 {
            return lhs.uuid.5 < rhs.uuid.5
        } else if lhs.uuid.6 != rhs.uuid.6 {
            return lhs.uuid.6 < rhs.uuid.6
        } else if lhs.uuid.7 != rhs.uuid.7 {
            return lhs.uuid.7 < rhs.uuid.7
        } else {
            return false
        }
    }
}
