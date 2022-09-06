//
//  CheckoutFlowTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 06/09/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class CheckoutFlowTests: XCTestCase {
    private var flow: CheckoutFlowImpl!
    
    private var userId: UserId!
    private var product: Product!
    private var checkoutService: CheckoutServiceMock!
    private var featuresService: PaidFeaturesServiceMock!
    private var paymentQueueInteractor: PaymentQueueInteractorMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        userId = .uuid(UUID())
        product = .mock(productIdentifier: UUID().uuidString)
        checkoutService = .init()
        featuresService = .init()
        paymentQueueInteractor = .init()
        
        flow = CheckoutFlowImpl(
            environment: .dev,
            userId: userId,
            product: product,
            checkoutService: checkoutService,
            featuresService: featuresService,
            paymentQueueInteractor: paymentQueueInteractor
        )
    }
    
    func testSuccessFlow() {
        let orderId = UUID()
        let transactionId = UUID().uuidString
        
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success(transactionId)
        checkoutService.completeResult = .success(())
        checkoutService.getResult = .success(.completed)
        featuresService.result = .success(PaidFeatures(features: [PaidFeature(name: "A feature", startDate: Date())]))
        
        
        let successCalled = expectation(description: "Success called")
        
        flow.start { result in
            guard case .success = result else {
                return
            }
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual(checkoutService.startUserId, userId)
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertEqual(checkoutService.completeOrderId, orderId)
        XCTAssertEqual(checkoutService.completTransactionId, transactionId)
        XCTAssertEqual(checkoutService.getOrderId, orderId)
        XCTAssertEqual(featuresService.userId, userId)
        XCTAssertNil(checkoutService.failOrderId)
    }
    
    func testNoReceiptFlow() {
        let orderId = UUID()
        let transactionId = UUID().uuidString
        
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success(transactionId)
        checkoutService.failResult = .success(())
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case .failure(let error) = result, case .noReceipt = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(checkoutService.startUserId, userId)
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertEqual(checkoutService.failOrderId, orderId)
        XCTAssertNil(checkoutService.completeOrderId)
        XCTAssertNil(checkoutService.getOrderId)
        XCTAssertNil(featuresService.userId)
    }
    
    private func collectTraceIds() -> Set<UUID> {
        Set(
            [
                checkoutService.startTraceId,
                checkoutService.logTraceId,
                checkoutService.getTraceId,
                checkoutService.failTraceId,
                checkoutService.completeTraceId
            ]
                .compactMap { $0 }
        )
    }
}
