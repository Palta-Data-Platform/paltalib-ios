//
//  PaidFeaturesServiceTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class PaidFeaturesServiceTests: XCTestCase {
    var featuresMock: FeaturesServiceMock!
    var subscriptionsMock: SubscriptionsServiceMock!
    var mapperMock: FeatureMapperMock!
    
    var service: PaidFeaturesServiceImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        featuresMock = .init()
        subscriptionsMock = .init()
        mapperMock = .init()
        
        service = PaidFeaturesServiceImpl(
            subscriptionsService: subscriptionsMock,
            featuresService: featuresMock,
            featureMapper: mapperMock
        )
    }
    
    func testSuccessWithSubscriptions() {
        let subscriptionId = UUID()
        let subscriptions = [Subscription.mock()]
        featuresMock.result = .success([.mock(lastSubscriptionId: subscriptionId)])
        subscriptionsMock.result = .success(subscriptions)
        let userId = UserId.uuid(UUID())
        let expectedFeatures = PaidFeatures(features: mapperMock.result)
        
        let completionCalled = expectation(description: "Success completion called")
        
        service.getPaidFeatures(for: userId) { result in
            guard case let .success(features) = result else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(featuresMock.userId, userId)
        XCTAssertEqual(subscriptionsMock.userId, userId)
        XCTAssertEqual(subscriptionsMock.ids, [subscriptionId])
        XCTAssertEqual(mapperMock.features, [.mock(lastSubscriptionId: subscriptionId)])
        XCTAssertEqual(mapperMock.subscriptions, subscriptions)
        XCTAssertEqual(featuresMock.traceId, subscriptionsMock.traceId)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testSuccessWithoutSubscriptions() {
        featuresMock.result = .success([.mock(lastSubscriptionId: nil)])
        let userId = UserId.uuid(UUID())
        let expectedFeatures = PaidFeatures(features: mapperMock.result)
        
        let completionCalled = expectation(description: "Success completion called")
        
        service.getPaidFeatures(for: userId) { result in
            guard case let .success(features) = result else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(featuresMock.userId, userId)
        XCTAssertNil(subscriptionsMock.userId)
        XCTAssertNil(subscriptionsMock.ids)
        XCTAssertEqual(mapperMock.features, [.mock(lastSubscriptionId: nil)])
        XCTAssertEqual(mapperMock.subscriptions, [])
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testFailOnFeatures() {
        featuresMock.result = .failure(.invalidKey)
        let userId = UserId.uuid(UUID())
        
        let completionCalled = expectation(description: "Fail completion called")
        
        service.getPaidFeatures(for: userId) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(featuresMock.userId, userId)
        XCTAssertNil(subscriptionsMock.userId)
        XCTAssertNil(subscriptionsMock.ids)
        XCTAssertNil(mapperMock.features)
        XCTAssertNil(mapperMock.subscriptions)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testFailOnSubscriptions() {
        featuresMock.result = .success([.mock(lastSubscriptionId: UUID())])
        subscriptionsMock.result = .failure(.networkError(URLError(.notConnectedToInternet)))
        let userId = UserId.uuid(UUID())
        
        let completionCalled = expectation(description: "Fail completion called")
        
        service.getPaidFeatures(for: userId) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertNil(mapperMock.features)
        XCTAssertNil(mapperMock.subscriptions)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
