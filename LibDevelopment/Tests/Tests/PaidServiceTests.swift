//
//  PaidServiceTests.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import XCTest
@testable import PaltaLibPayments

final class PaidServiceTests: XCTestCase {
    func testLifetime() {
        let paidService = PaidService(
            name: "A name",
            startDate: Date(),
            endDate: nil
        )
        
        XCTAssert(paidService.isLifetime)
        XCTAssert(paidService.isActive)
    }
    
    func testNotLifetime() {
        let paidService = PaidService(
            name: "A name",
            startDate: Date(),
            endDate: Date(timeIntervalSinceNow: 12)
        )
        
        XCTAssertFalse(paidService.isLifetime)
    }
    
    func testBeforeBegin() {
        let paidService = PaidService(
            name: "A name",
            startDate: Date(timeIntervalSinceNow: 5),
            endDate: Date(timeIntervalSinceNow: 12)
        )
        
        XCTAssertFalse(paidService.isActive)
    }
    
    func testActive() {
        let paidService = PaidService(
            name: "A name",
            startDate: Date(timeIntervalSinceNow: -5),
            endDate: Date(timeIntervalSinceNow: 12)
        )
        
        XCTAssert(paidService.isActive)
    }
    
    func testAfterEnd() {
        let paidService = PaidService(
            name: "A name",
            startDate: Date(timeIntervalSinceNow: -50),
            endDate: Date(timeIntervalSinceNow: -12)
        )
        
        XCTAssertFalse(paidService.isActive)
    }
}
