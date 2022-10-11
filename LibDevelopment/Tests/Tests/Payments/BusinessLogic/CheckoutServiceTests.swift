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
    
    private var environment: Environment!
    private var httpMock: HTTPClientMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        environment = URL(string: "http://\(UUID())")
        httpMock = .init()
        checkoutService = .init(environment: environment, httpClient: httpMock)
    }
    
    func testStartSuccess() {
        let userId = UserId.uuid(UUID())
        let expectedOrderId = UUID()
        let ident = UUID().uuidString
        let traceId = UUID()
        
        httpMock.result = .success(StartCheckoutResponse(status: "OK", orderId: expectedOrderId))
        
        let successCalled = expectation(description: "Success called")
        
        checkoutService.startCheckout(userId: userId, ident: ident, traceId: traceId) { result in
            guard case let .success(orderId) = result else {
                return
            }
            
            XCTAssertEqual(orderId, expectedOrderId)
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .startCheckout(userId, ident))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.traceId, traceId)
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, environment)
    }
    
    func testStartFailure() {
        httpMock.result = .failure(NetworkErrorWithoutResponse.noData)
        let failCalled = expectation(description: "Fail called")
        
        checkoutService.startCheckout(userId: .uuid(UUID()), ident: "", traceId: UUID()) { result in
            guard case .failure = result else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
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
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, environment)
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
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, environment)
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
    
    func testGetCheckoutSuccess() {
        let orderId = UUID()
        let traceId = UUID()
        
        httpMock.result = .success(GetCheckoutReponse(status: "ok", state: .failed))
        
        let successCalled = expectation(description: "Success called")
        
        checkoutService.getCheckout(orderId: orderId, traceId: traceId) { result in
            guard case .success(let state) = result else {
                return
            }
            
            XCTAssertEqual(state, .failed)
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .getCheckout(orderId))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.traceId, traceId)
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, environment)
    }
    
    func testGetCheckoutFailure() {
        httpMock.result = .failure(NetworkErrorWithoutResponse.decodingError(nil))
        let failCalled = expectation(description: "Fail called")
        
        checkoutService.getCheckout(orderId: UUID(), traceId: UUID()) { result in
            guard case .failure = result else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testLogNoData() {
        let traceId = UUID()
        
        httpMock.result = .success(StatusReponse(status: "ok"))
        
        checkoutService.log(level: .info, event: "An event", data: nil, traceId: traceId)
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .log(.info, "An event", nil))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.traceId, traceId)
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, environment)
    }
    
    func testLogWithData() {
        let traceId = UUID()
        
        httpMock.result = .success(StatusReponse(status: "ok"))
        
        checkoutService.log(level: .error, event: "event", data: ["some": 10.5], traceId: traceId)
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .log(.error, "event", ["some": 10.5]))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.traceId, traceId)
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.environment, environment)
    }
}
