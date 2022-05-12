//
//  PaidServicesTests.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import XCTest
@testable import PaltaLibPayments

final class PaidServicesTests: XCTestCase {
    func testEmptyInit() {
        XCTAssertEqual(PaidServices(), PaidServices(services: []))
    }
    
    func testMerge1() {
        let s1 = [
            PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
            PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date()),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil),
            PaidService(name: "Name 3", startDate: Date(timeIntervalSinceNow: -80), endDate: Date())
        ]
        
        let services1 = PaidServices(services: s1)
        
        let s2 = [
            PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: 10), endDate: nil),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: -98), endDate: Date()),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: 5), endDate: nil),
            PaidService(name: "Name 4", startDate: Date(timeIntervalSinceNow: -88), endDate: Date())
        ]
        
        var services2 = PaidServices(services: s2)
        
        let expectedMerged = PaidServices(
            services: s1 + s2
        )
        
        services2.merge(with: services1)
        
        XCTAssertEqual(services2, expectedMerged)
    }
    
    func testMerge2() {
        let s1 = [
            PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
            PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date()),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: -80), endDate: Date())
        ]
        
        let services1 = PaidServices(services: s1)
        
        let s2 =  [
            PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: 10), endDate: nil),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: -98), endDate: Date()),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: 5), endDate: nil),
            PaidService(name: "Name 3", startDate: Date(timeIntervalSinceNow: -88), endDate: Date())
        ]
        
        let services2 = PaidServices(services: s2)
        
        let expectedMerged = PaidServices(
            services: s1 + s2
        )
        
        XCTAssertEqual(services1.merged(with: services2), expectedMerged)
    }
    
    func testHasActiveSubscriptionTrue() {
        let services = PaidServices(
            services: [
                PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: -1), endDate: nil),
                PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date(timeIntervalSinceNow: -3)),
                PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil)
            ]
        )
        
        XCTAssert(services.hasActiveService(with: "Name 1"))
    }
    
    func testHasActiveSubscriptionFalse() {
        let services = PaidServices(
            services: [
                PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
                PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date(timeIntervalSinceNow: -3)),
                PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil)
            ]
        )
        
        XCTAssertFalse(services.hasActiveService(with: "Name 2"))
    }
    
    func testHasActiveSubscriptionNoService() {
        let services = PaidServices(
            services: [
                PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
                PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date(timeIntervalSinceNow: -3)),
                PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil)
            ]
        )
        
        XCTAssertFalse(services.hasActiveService(with: "Name 3"))
    }
    
    func testToArray() {
        let serviceSet: Set<PaidService> = [
            PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
            PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date()),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: -80), endDate: Date()),
            PaidService(name: "Name 1", startDate: Date(timeIntervalSinceNow: 10), endDate: nil),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: -98), endDate: Date()),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSinceNow: 5), endDate: nil),
            PaidService(name: "Name 3", startDate: Date(timeIntervalSinceNow: -88), endDate: Date())
        ]
        
        let services = PaidServices(services: Array(serviceSet))
        
        XCTAssertEqual(Set(services.services), serviceSet)
    }
    
    func testSubscript() {
        let services = PaidServices(
            services: [
                PaidService(name: "Name 1", startDate: Date(timeIntervalSince1970: 1), endDate: nil),
                PaidService(name: "Name 1", startDate: Date(timeIntervalSince1970: -8), endDate: Date(timeIntervalSince1970: 0)),
                PaidService(name: "Name 2", startDate: Date(timeIntervalSince1970: 55), endDate: nil),
                PaidService(name: "Name 2", startDate: Date(timeIntervalSince1970: -80), endDate: Date(timeIntervalSince1970: 0)),
                PaidService(name: "Name 1", startDate: Date(timeIntervalSince1970: 10), endDate: nil),
                PaidService(name: "Name 2", startDate: Date(timeIntervalSince1970: -98), endDate: Date(timeIntervalSince1970: 0)),
                PaidService(name: "Name 2", startDate: Date(timeIntervalSince1970: 5), endDate: nil),
                PaidService(name: "Name 3", startDate: Date(timeIntervalSince1970: -88), endDate: Date(timeIntervalSince1970: 0))
            ]
        )
        
        let serviceSet = Set(services["Name 2"])
        
        let expectedServiceSet: Set<PaidService> = [
            PaidService(name: "Name 2", startDate: Date(timeIntervalSince1970: 55), endDate: nil),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSince1970: -80), endDate: Date(timeIntervalSince1970: 0)),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSince1970: -98), endDate: Date(timeIntervalSince1970: 0)),
            PaidService(name: "Name 2", startDate: Date(timeIntervalSince1970: 5), endDate: nil)
        ]
        
        XCTAssertEqual(serviceSet, expectedServiceSet)
    }
}
