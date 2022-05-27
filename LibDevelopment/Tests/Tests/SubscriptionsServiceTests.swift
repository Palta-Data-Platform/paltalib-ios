//
//  SubscriptionsServiceTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import XCTest
import PaltaLibCore
@testable import PaltaLibPayments

final class SubscriptionsServiceTests: XCTestCase {
    var httpMock: HTTPClientMock!
    var service: SubscriptionsServiceImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        httpMock = .init()
        service = SubscriptionsServiceImpl(httpClient: httpMock)
    }
    
    func testSuccess() {
        let userId = UserId.uuid(.init())
        let ids: Set<UUID> = [.init(), .init()]
        let expectedSubscriptions = [Subscription.mock()]
        httpMock.result = .success(SubscriptionResponse(subscriptions: expectedSubscriptions))
        
        let completionCalled = expectation(description: "Success completion called")
        
        service.getSubscriptions(with: ids, for: userId) { result in
            guard case let .success(subscriptions) = result else {
                return
            }
            
            XCTAssertEqual(subscriptions, expectedSubscriptions)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(httpMock.request as? PaymentsHTTPRequest, .getSubcriptions(userId, ids))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testFailure() {
        let userId = UserId.uuid(.init())
        let ids: Set<UUID> = [.init(), .init()]
        httpMock.result = .failure(NetworkErrorWithoutResponse.invalidStatusCode(404, nil))
        
        let completionCalled = expectation(description: "Failure completion called")
        
        service.getSubscriptions(with: ids, for: userId) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(httpMock.request as? PaymentsHTTPRequest, .getSubcriptions(userId, ids))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
