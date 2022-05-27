//
//  PaidFeatureTests.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import XCTest
@testable import PaltaLibPayments

final class PaidFeatureTests: XCTestCase {
    func testLifetime() {
        let paidFeature = PaidFeature(
            name: "A name",
            startDate: Date(),
            endDate: nil
        )
        
        XCTAssert(paidFeature.isLifetime)
        XCTAssert(paidFeature.isActive)
    }
    
    func testNotLifetime() {
        let paidFeature = PaidFeature(
            name: "A name",
            startDate: Date(),
            endDate: Date(timeIntervalSinceNow: 12)
        )
        
        XCTAssertFalse(paidFeature.isLifetime)
    }
    
    func testBeforeBegin() {
        let paidFeature = PaidFeature(
            name: "A name",
            startDate: Date(timeIntervalSinceNow: 5),
            endDate: Date(timeIntervalSinceNow: 12)
        )
        
        XCTAssertFalse(paidFeature.isActive)
    }
    
    func testActive() {
        let paidFeature = PaidFeature(
            name: "A name",
            startDate: Date(timeIntervalSinceNow: -5),
            endDate: Date(timeIntervalSinceNow: 12)
        )
        
        XCTAssert(paidFeature.isActive)
    }
    
    func testAfterEnd() {
        let paidFeature = PaidFeature(
            name: "A name",
            startDate: Date(timeIntervalSinceNow: -50),
            endDate: Date(timeIntervalSinceNow: -12)
        )
        
        XCTAssertFalse(paidFeature.isActive)
    }
}
