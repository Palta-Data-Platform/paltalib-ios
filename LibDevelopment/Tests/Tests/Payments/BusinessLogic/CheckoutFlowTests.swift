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
    
    private var environment: Environment!
    private var userId: UserId!
    private var product: ShowcaseProduct!
    private var checkoutService: CheckoutServiceMock!
    private var featuresService: PaidFeaturesServiceMock!
    private var paymentQueueInteractor: PaymentQueueInteractorMock!
    private var receiptProvider: ReceiptProviderMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        environment = Environment(string: "http://\(UUID())")
        userId = .uuid(UUID())
        product = .mock(productIdentifier: UUID().uuidString)
        checkoutService = .init()
        featuresService = .init()
        paymentQueueInteractor = .init()
        receiptProvider = .init()
        
        flow = CheckoutFlowImpl(
            environment: environment,
            userId: userId,
            product: product,
            checkoutService: checkoutService,
            featuresService: featuresService,
            paymentQueueInteractor: paymentQueueInteractor,
            receiptProvider: receiptProvider
        )
    }
    
    func testSuccessFlow() {
        let orderId = UUID()
        let transactionId = UUID().uuidString
        let receiptData = Data((0...20).map { _ in UInt8.random(in: 0...255) })
        
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success(transactionId)
        receiptProvider.data = receiptData
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
        XCTAssertEqual(checkoutService.startIdent, product.ident)
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertEqual(checkoutService.completeOrderId, orderId)
        XCTAssertEqual(checkoutService.completeReceiptData, receiptData)
        XCTAssertEqual(checkoutService.completTransactionId, transactionId)
        XCTAssertEqual(checkoutService.getOrderId, orderId)
        XCTAssertEqual(featuresService.userId, userId)
        XCTAssertEqual(paymentQueueInteractor.closedTransactions, [transactionId])
        XCTAssertNil(checkoutService.failOrderId)
    }
    
    func testFailStartCheckout() {
        checkoutService.startResult = .failure(.networkError(URLError(.appTransportSecurityRequiresSecureConnection)))
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case .failure(let error) = result, case .networkError = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(checkoutService.startUserId, userId)
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertNil(checkoutService.completeOrderId)
        XCTAssertNil(checkoutService.failOrderId)
        XCTAssertNil(checkoutService.getOrderId)
        XCTAssertNil(featuresService.userId)
        XCTAssertEqual(paymentQueueInteractor.closedTransactions, [])
        XCTAssertNil(paymentQueueInteractor.product)
    }
    
    func testFailPurchaseFlow() {
        let orderId = UUID()
        
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .failure(.cancelledByUser)
        checkoutService.failResult = .success(())
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case .failure(let error) = result, case .cancelledByUser = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(checkoutService.startUserId, userId)
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertEqual(checkoutService.failOrderId, orderId)
        XCTAssertEqual(paymentQueueInteractor.closedTransactions, [])
        XCTAssertNil(checkoutService.getOrderId)
        XCTAssertNil(featuresService.userId)
    }
    
    func testNoReceiptFlow() {
        let orderId = UUID()
        let transactionId = UUID().uuidString
        
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success(transactionId)
        receiptProvider.data = nil
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
        XCTAssertEqual(paymentQueueInteractor.closedTransactions, [])
        XCTAssertNil(checkoutService.completeOrderId)
        XCTAssertNil(checkoutService.getOrderId)
        XCTAssertNil(featuresService.userId)
    }
    
    func testCompleteFailedFlow() {
        let orderId = UUID()
        let transactionId = UUID().uuidString
        
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success(transactionId)
        receiptProvider.data = Data()
        checkoutService.completeResult = .failure(.networkError(URLError(.badURL)))
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case .failure(let error) = result, case .flowNotCompleted = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(checkoutService.startUserId, userId)
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertEqual(checkoutService.completeOrderId, orderId)
        XCTAssertEqual(paymentQueueInteractor.closedTransactions, [])
        XCTAssertNil(checkoutService.getOrderId)
        XCTAssertNil(featuresService.userId)
    }
    
    func testFlowCancelled() {
        let orderId = UUID()
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success("")
        receiptProvider.data = Data()
        checkoutService.completeResult = .success(())
        checkoutService.getResult = .success(.cancelled)
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case .failure(let error) = result, case .flowFailed(let failedOrderId) = error else {
                return
            }
            
            XCTAssertEqual(failedOrderId, orderId)
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertNil(featuresService.userId)
    }
    
    func testFlowFailed() {
        let orderId = UUID()
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success("")
        receiptProvider.data = Data()
        checkoutService.completeResult = .success(())
        checkoutService.getResult = .success(.failed)
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case .failure(let error) = result, case .flowFailed(let failedOrderId) = error else {
                return
            }
            
            XCTAssertEqual(failedOrderId, orderId)
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertNil(featuresService.userId)
    }
    
    func testFlowPending() {
        let orderId = UUID()
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success("")
        receiptProvider.data = Data()
        checkoutService.completeResult = .success(())
        checkoutService.getResult = .success(.processing)
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case .failure(let error) = result, case .flowNotCompleted = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertNil(featuresService.userId)
    }
    
    func testGetCheckoutFailedFlow() {
        let orderId = UUID()
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success("")
        receiptProvider.data = Data()
        checkoutService.completeResult = .success(())
        checkoutService.getResult = .failure(.networkError(URLError(.cannotFindHost)))
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case .failure(let error) = result, case .flowNotCompleted = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
        XCTAssertNil(featuresService.userId)
    }
    
    func testGetFeaturesFailedFlow() {
        let orderId = UUID()
        checkoutService.startResult = .success(orderId)
        paymentQueueInteractor.result = .success("")
        receiptProvider.data = Data()
        checkoutService.completeResult = .success(())
        checkoutService.getResult = .success(.completed)
        featuresService.result = .failure(.sdkError(.protocolError))
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case .failure(let error) = result, case .flowNotCompleted = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(collectTraceIds().count, 1) // The same trace id is passed everywhere
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
