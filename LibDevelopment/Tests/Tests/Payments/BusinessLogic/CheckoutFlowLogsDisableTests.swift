//
//  CheckoutFlowLogsDisableTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 06/09/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class CheckoutFlowLogsDisableTests: XCTestCase {
    private var flow: CheckoutFlowImpl!
    
    private var userId: UserId!
    private var product: Product!
    private var checkoutService: CheckoutServiceMock!
    private var featuresService: PaidFeaturesServiceMock!
    private var paymentQueueInteractor: PaymentQueueInteractorMock!
    private var receiptProvider: ReceiptProviderMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        userId = .uuid(UUID())
        product = .mock(productIdentifier: UUID().uuidString)
        checkoutService = .init()
        featuresService = .init()
        paymentQueueInteractor = .init()
        receiptProvider = .init()
        
        flow = CheckoutFlowImpl(
            environment: .prod,
            userId: userId,
            product: product,
            checkoutService: checkoutService,
            featuresService: featuresService,
            paymentQueueInteractor: paymentQueueInteractor,
            receiptProvider: receiptProvider
        )
        
        checkoutService.startResult = .success(UUID())
        checkoutService.completeResult = .success(())
        checkoutService.getResult = .success(.completed)
        checkoutService.failResult = .success(())
        
        receiptProvider.data = Data()
        
        paymentQueueInteractor.result = .success("")
        featuresService.result = .success(PaidFeatures())
    }
    
    func testSuccessFlow() {
        let flowFinished = expectation(description: "Flow finished")
        
        flow.start { _ in
            flowFinished.fulfill()
        }
        
        wait(for: [flowFinished], timeout: 0.1)
        
        XCTAssertNil(checkoutService.logEvent)
    }
    
    func testFailStart() {
        checkoutService.startResult = .failure(.noUserId)
        let flowFinished = expectation(description: "Flow finished")
        
        flow.start { _ in
            flowFinished.fulfill()
        }
        
        wait(for: [flowFinished], timeout: 0.1)
        
        XCTAssertNil(checkoutService.logEvent)
    }
    
    func testFailPurchase() {
        paymentQueueInteractor.result = .failure(.noUserId)
        let flowFinished = expectation(description: "Flow finished")
        
        flow.start { _ in
            flowFinished.fulfill()
        }
        
        wait(for: [flowFinished], timeout: 0.1)
        
        XCTAssertNil(checkoutService.logEvent)
    }
    
    func testFailReceipt() {
        receiptProvider.data = nil
        let flowFinished = expectation(description: "Flow finished")
        
        flow.start { _ in
            flowFinished.fulfill()
        }
        
        wait(for: [flowFinished], timeout: 0.1)
        
        XCTAssertNil(checkoutService.logEvent)
    }
    
    func testFailComplete() {
        checkoutService.completeResult = .failure(.noUserId)
        let flowFinished = expectation(description: "Flow finished")
        
        flow.start { _ in
            flowFinished.fulfill()
        }
        
        wait(for: [flowFinished], timeout: 0.1)
        
        XCTAssertNil(checkoutService.logEvent)
    }
    
    func testFailGet() {
        checkoutService.getResult = .failure(.noUserId)
        let flowFinished = expectation(description: "Flow finished")
        
        flow.start { _ in
            flowFinished.fulfill()
        }
        
        wait(for: [flowFinished], timeout: 0.1)
        
        XCTAssertNil(checkoutService.logEvent)
    }
    
    func testFailFeatures() {
        featuresService.result = .failure(.noUserId)
        let flowFinished = expectation(description: "Flow finished")
        
        flow.start { _ in
            flowFinished.fulfill()
        }
        
        wait(for: [flowFinished], timeout: 0.1)
        
        XCTAssertNil(checkoutService.logEvent)
    }
}
