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
    var environment: Environment!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        httpMock = .init()
        environment = URL(string: "https://mock.mock/\(UUID())")
        service = SubscriptionsServiceImpl(environment: environment, httpClient: httpMock)
    }
    
    func testSuccess() {
        let userId = UserId.uuid(.init())
        let ids: Set<UUID> = [.init(), .init()]
        let expectedSubscriptions = [Subscription.mock()]
        let traceId = UUID()
        httpMock.result = .success(SubscriptionResponse(subscriptions: expectedSubscriptions))
        
        let completionCalled = expectation(description: "Success completion called")
        
        service.getSubscriptions(with: ids, for: userId, traceId: traceId) { result in
            guard case let .success(subscriptions) = result else {
                return
            }
            
            XCTAssertEqual(subscriptions, expectedSubscriptions)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .getSubcriptions(userId, ids))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.traceId, traceId)
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, environment)
        
        wait(for: [completionCalled], timeout: 0.1)
    }

    func testFailure() {
        let userId = UserId.uuid(.init())
        let ids: Set<UUID> = [.init(), .init()]
        httpMock.result = .failure(NetworkErrorWithoutResponse.invalidStatusCode(404, nil))
        
        let completionCalled = expectation(description: "Failure completion called")
        
        service.getSubscriptions(with: ids, for: userId, traceId: UUID()) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .getSubcriptions(userId, ids))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, environment)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
