//
//  FeatureMapperTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
@testable import PaltaLibPayments
import XCTest

final class FeatureMapperTests: XCTestCase {
    var mapper: FeatureMapperImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mapper = FeatureMapperImpl()
    }
    
    func testBaseMapping() {
        let features = [
            Feature(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                feature: "sku1",
                lastSubscriptionId: nil
            )
        ]
        
        let paidFeatures = mapper.map(features, and: [])
        
        XCTAssertEqual(paidFeatures.first?.name, "sku1")
        XCTAssertEqual(paidFeatures.first?.startDate, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(paidFeatures.first?.endDate, Date(timeIntervalSince1970: 100))
        XCTAssertNil(paidFeatures.first?.cancellationDate)
        XCTAssertNil(paidFeatures.first?.productIdentifier)
        XCTAssertEqual(paidFeatures.first?.isTrial, false)
        XCTAssertEqual(paidFeatures.first?.paymentType, .oneOff)
        XCTAssertEqual(paidFeatures.first?.transactionType, .web)
    }
    
    func testTrial() {
        let subscriptionId = UUID()
        
        let features = [
            Feature(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                feature: "sku1",
                lastSubscriptionId: subscriptionId
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
        
        let paidFeatures = mapper.map(features, and: subscriptions)

        XCTAssertEqual(paidFeatures.first?.isTrial, true)
    }
    
    func testCancelled() {
        let subscriptionId = UUID()
        
        let features = [
            Feature(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                feature: "sku1",
                lastSubscriptionId: subscriptionId
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
        
        let paidFeatures = mapper.map(features, and: subscriptions)
        
        XCTAssertEqual(paidFeatures.first?.name, "sku1")
        XCTAssertEqual(paidFeatures.first?.startDate, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(paidFeatures.first?.endDate, Date(timeIntervalSince1970: 100))
        XCTAssertEqual(paidFeatures.first?.cancellationDate, Date(timeIntervalSince1970: 50))
        XCTAssertEqual(paidFeatures.first?.isTrial, false)
    }
}
