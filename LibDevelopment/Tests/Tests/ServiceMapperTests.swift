//
//  ServiceMapperTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
@testable import PaltaLibPayments
import XCTest

final class ServiceMapperTests: XCTestCase {
    var mapper: ServiceMapperImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mapper = ServiceMapperImpl()
    }
    
    func testBaseMapping() {
        let services = [
            Service(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                sku: "sku1"
            )
        ]
        
        let paidServices = mapper.map(services, and: [])
        
        XCTAssertEqual(paidServices.first?.name, "sku1")
        XCTAssertEqual(paidServices.first?.startDate, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(paidServices.first?.endDate, Date(timeIntervalSince1970: 100))
        XCTAssertNil(paidServices.first?.cancellationDate)
        XCTAssertNil(paidServices.first?.productIdentifier)
        XCTAssertEqual(paidServices.first?.isTrial, false)
        XCTAssertEqual(paidServices.first?.paymentType, .oneOff)
        XCTAssertEqual(paidServices.first?.transactionType, .web)
    }
    
    func testTrial() {
        let subscriptionId = UUID()
        
        let services = [
            Service(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                sku: "sku1"
            )
        ]
        
        let subscriptions = [
            Subscription(
                id: subscriptionId,
                state: .active,
                createdAt: Date(),
                canceledAt: Date(),
                currentPeriodStartAt: Date(),
                currentPeriodEndAt: Date(),
                tags: [.trial]
            )
        ]
        
        let paidServices = mapper.map(services, and: subscriptions)

        XCTAssertEqual(paidServices.first?.isTrial, true)
    }
    
    func testCancelled() {
        let subscriptionId = UUID()
        
        let services = [
            Service(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                sku: "sku1"
            )
        ]
        
        let subscriptions = [
            Subscription(
                id: subscriptionId,
                state: .active,
                createdAt: Date(),
                canceledAt: Date(timeIntervalSince1970: 50),
                currentPeriodStartAt: Date(),
                currentPeriodEndAt: Date(),
                tags: [.trial]
            )
        ]
        
        let paidServices = mapper.map(services, and: subscriptions)
        
        XCTAssertEqual(paidServices.first?.name, "sku1")
        XCTAssertEqual(paidServices.first?.startDate, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(paidServices.first?.endDate, Date(timeIntervalSince1970: 100))
        XCTAssertEqual(paidServices.first?.cancellationDate, Date(timeIntervalSince1970: 50))
        XCTAssertEqual(paidServices.first?.isTrial, false)
    }
}
