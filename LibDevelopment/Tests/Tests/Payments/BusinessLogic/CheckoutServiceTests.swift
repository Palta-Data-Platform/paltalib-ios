//
//  CheckoutServiceTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 26/08/2022.
//

import Foundation
import XCTest
import PaltaLibCore
@testable import PaltaLibPayments

final class CheckoutServiceTests: XCTestCase {
    private var checkoutService: CheckoutServiceImpl!
    
    private var httpMock: HTTPClientMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        httpMock = .init()
        checkoutService = .init(environment: .dev, httpClient: httpMock)
    }
    
    func testStartSuccess() {
        let userId = UserId.uuid(UUID())
        let expectedOrderId = UUID()
        let traceId = UUID()
        
        httpMock.result = .success(StartCheckoutResponse(status: "OK", orderId: expectedOrderId))
        
        let successCalled = expectation(description: "Success called")
        
        checkoutService.startCheckout(userId: userId, traceId: traceId) { result in
            guard case let .success(orderId) = result else {
                return
            }
            
            XCTAssertEqual(orderId, expectedOrderId)
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .startCheckout(userId))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.traceId, traceId)
    }
    
    func testStartFailure() {
        httpMock.result = .failure(NetworkErrorWithoutResponse.noData)
        let failCalled = expectation(description: "Fail called")
        
        checkoutService.startCheckout(userId: .uuid(UUID()), traceId: UUID()) { result in
            guard case .failure = result else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testStartProdEnv() {
        checkoutService = .init(environment: .prod, httpClient: httpMock)
        
        checkoutService.startCheckout(userId: .uuid(UUID()), traceId: UUID(), completion: { _ in })
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, .prod)
    }
    
    func testStartDevEnv() {
        checkoutService = .init(environment: .dev, httpClient: httpMock)
        
        checkoutService.startCheckout(userId: .uuid(UUID()), traceId: UUID(), completion: { _ in })
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, .dev)
    }
    
    func testCompleteSuccess() {
        let receiptData = Data(0...100)
        let orderId = UUID()
        let traceId = UUID()
        let transactionId = UUID().uuidString
        
        httpMock.result = .success(StatusReponse(status: "ok"))
        
        let successCalled = expectation(description: "Success called")
        
        checkoutService.completeCheckout(orderId: orderId, receiptData: receiptData, transactionId: transactionId, traceId: traceId) { result in
            guard case .success = result else {
                return
            }
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .checkoutCompleted(orderId, receiptData.base64EncodedString(), transactionId))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.traceId, traceId)
    }
    
    func testCompleteFailure() {
        httpMock.result = .failure(NetworkErrorWithoutResponse.noData)
        let failCalled = expectation(description: "Fail called")
        
        checkoutService.completeCheckout(orderId: UUID(), receiptData: Data(), transactionId: "", traceId: UUID()) { result in
            guard case .failure = result else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testCompleteProdEnv() {
        checkoutService = .init(environment: .prod, httpClient: httpMock)
        
        checkoutService.completeCheckout(orderId: UUID(), receiptData: Data(), transactionId: "", traceId: UUID(), completion: { _ in })
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, .prod)
    }
    
    func testCompleteDevEnv() {
        checkoutService = .init(environment: .dev, httpClient: httpMock)
        
        checkoutService.completeCheckout(orderId: UUID(), receiptData: Data(), transactionId: "", traceId: UUID(), completion: { _ in })
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, .dev)
    }
    
    func testFailSuccess() {
        let orderId = UUID()
        let traceId = UUID()
        
        httpMock.result = .success(StatusReponse(status: "ok"))
        
        let successCalled = expectation(description: "Success called")
        
        checkoutService.failCheckout(orderId: orderId, traceId: traceId) { result in
            guard case .success = result else {
                return
            }
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .checkoutFailed(orderId))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.traceId, traceId)
    }
    
    func testFailFailure() {
        httpMock.result = .failure(NetworkErrorWithoutResponse.noData)
        let failCalled = expectation(description: "Fail called")
        
        checkoutService.failCheckout(orderId: UUID(), traceId: UUID()) { result in
            guard case .failure = result else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testFailProdEnv() {
        checkoutService = .init(environment: .prod, httpClient: httpMock)
        
        checkoutService.failCheckout(orderId: UUID(), traceId: UUID(), completion: { _ in })
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, .prod)
    }
    
    func testFailDevEnv() {
        checkoutService = .init(environment: .dev, httpClient: httpMock)
        
        checkoutService.failCheckout(orderId: UUID(), traceId: UUID(), completion: { _ in })
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, .dev)
    }
}
