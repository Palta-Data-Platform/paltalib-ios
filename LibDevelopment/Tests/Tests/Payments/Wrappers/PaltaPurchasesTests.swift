//
//  PaltaPurchasesTests.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class PaltaPurchasesTests: XCTestCase {
    var instance: PaltaPurchases!
    var mockPlugins: [PurchasePluginMock] = []
    var delegateMock: PaltaPurchasesDelegateMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockPlugins = (0...2).map { _ in PurchasePluginMock() }
        instance = PaltaPurchases()
        instance.setup(with: mockPlugins)
        delegateMock = .init()
        instance.delegate = delegateMock
    }
    
    func testConfigure() {
        let plugins = (1...3).map { _ in PurchasePluginMock() }
        let instance = PaltaPurchases()
        instance.setup(with: plugins)

        XCTAssert(instance.setupFinished)
        XCTAssertEqual(instance.plugins as? [PurchasePluginMock], plugins)
    }
    
    func testLoginSuccess() {
        let userId = UserId.uuid(UUID())
        let successCalled = expectation(description: "Login success")
        
        instance.logIn(appUserId: userId) {
            guard case .success = $0 else {
                return
            }
            
            successCalled.fulfill()
        }
        
        checkPlugins {
            $0.logInUserId == userId
        }
        
        DispatchQueue.concurrentPerform(iterations: mockPlugins.count) { [mockPlugins] i in
            mockPlugins[i].logInCompletion?(.success(()))
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual(instance.userId, userId)
    }
    
    func testLoginFail() {
        let userId = UserId.uuid(UUID())
        let failCalled = expectation(description: "Login fail")
        
        instance.logIn(appUserId: userId) {
            guard case .failure = $0 else {
                return
            }
            
            failCalled.fulfill()
        }
        
        checkPlugins {
            $0.logInUserId == userId
        }
        
        let failedIndex = Int.random(in: 0..<mockPlugins.count)
        DispatchQueue.concurrentPerform(iterations: mockPlugins.count) { [mockPlugins] i in
            mockPlugins[i].logInCompletion?(
                i == failedIndex ? .success(()) : .failure(PaymentsError.invalidKey)
            )
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertNil(instance.userId)
        
        checkPlugins {
            $0.logOutCalled
        }
    }
    
    func testLogOut() {
        let loggedIn = expectation(description: "Logged in")
        instance.logIn(appUserId: .uuid(UUID())) { _ in
            loggedIn.fulfill()
        }
        
        mockPlugins.forEach {
            $0.logInCompletion?(.success(()))
        }
        
        wait(for: [loggedIn], timeout: 0.1)
        
        instance.logOut()
        
        checkPlugins {
            $0.logOutCalled
        }
        
        XCTAssertNil(instance.userId)
    }
    
    func testGetPaidFeaturesSuccess() {
        let pluginFeatures = [
            PaidFeatures(
                features: [
                    PaidFeature(name: "Feature 1", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                    PaidFeature(name: "Feature 2", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                    PaidFeature(name: "Feature 3", startDate: Date(timeIntervalSince1970: 0), endDate: nil)
                ]
            ),
            PaidFeatures(),
            PaidFeatures(
                features: [
                    PaidFeature(name: "Feature 6", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                    PaidFeature(name: "Feature 2", startDate: Date(timeIntervalSince1970: 88), endDate: nil),
                    PaidFeature(name: "Feature 5", startDate: Date(timeIntervalSince1970: 0), endDate: nil)
                ]
            )
        ]
        
        assert(mockPlugins.count == pluginFeatures.count)
        
        let expectedFeatures = PaidFeatures(
            features: [
                PaidFeature(name: "Feature 1", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                PaidFeature(name: "Feature 2", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                PaidFeature(name: "Feature 3", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                PaidFeature(name: "Feature 6", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                PaidFeature(name: "Feature 2", startDate: Date(timeIntervalSince1970: 88), endDate: nil),
                PaidFeature(name: "Feature 5", startDate: Date(timeIntervalSince1970: 0), endDate: nil)
            ]
        )
        
        let completionCalled = expectation(description: "Get paid features completed successfully")
        
        instance.getPaidFeatures { result in
            guard case .success(let features) = result else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            
            completionCalled.fulfill()
        }
        
        checkPlugins {
            $0.getPaidFeaturesCompletion != nil
        }
        
        DispatchQueue.concurrentPerform(iterations: mockPlugins.count) { iteration in
            mockPlugins[iteration].getPaidFeaturesCompletion?(.success(pluginFeatures[iteration]))
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetPaidFeaturesOneError() {
        let pluginFeatures = [
            PaidFeatures(
                features: [
                    PaidFeature(name: "Feature 1", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                    PaidFeature(name: "Feature 2", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                    PaidFeature(name: "Feature 3", startDate: Date(timeIntervalSince1970: 0), endDate: nil)
                ]
            ),
            PaidFeatures()
        ]
        
        let completionCalled = expectation(description: "Get paid features completed with fail 1")
        
        instance.getPaidFeatures { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        checkPlugins {
            $0.getPaidFeaturesCompletion != nil
        }
        
        DispatchQueue.concurrentPerform(iterations: mockPlugins.count) { iteration in
            mockPlugins[iteration].getPaidFeaturesCompletion?(
                pluginFeatures.indices.contains(iteration)
                ? .success(pluginFeatures[iteration])
                : .failure(NSError(domain: "", code: 0))
            )
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetPaidFeaturesAllErrors() {
        let completionCalled = expectation(description: "Get paid features completed with fail 2")
        
        instance.getPaidFeatures { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        checkPlugins {
            $0.getPaidFeaturesCompletion != nil
        }
        
        DispatchQueue.concurrentPerform(iterations: mockPlugins.count) { iteration in
            mockPlugins[iteration].getPaidFeaturesCompletion?(.failure(NSError(domain: "", code: 0)))
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPromoOfferFirstSuccess() {
        let completionCalled = expectation(description: "Get promo offer completed 1")
        
        instance.getPromotionalOffer(for: ProductDiscountMock(), product: .mock()) { result in
            guard case .success = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertNotNil(mockPlugins[0].getPromotionalOfferCompletion)
        XCTAssertNil(mockPlugins[1].getPromotionalOfferCompletion)
        XCTAssertNil(mockPlugins[2].getPromotionalOfferCompletion)
        
        mockPlugins[0].getPromotionalOfferCompletion?(.success(PromoOfferMock()))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPromoOfferFirstFail() {
        let completionCalled = expectation(description: "Get promo offer completed 2")
        
        instance.getPromotionalOffer(for: ProductDiscountMock(), product: .mock()) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertNotNil(mockPlugins[0].getPromotionalOfferCompletion)
        XCTAssertNil(mockPlugins[1].getPromotionalOfferCompletion)
        XCTAssertNil(mockPlugins[2].getPromotionalOfferCompletion)
        
        mockPlugins[0].getPromotionalOfferCompletion?(.failure(NSError(domain: "", code: 0)))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPromoOfferLastSuccess() {
        let completionCalled = expectation(description: "Get promo offer completed 3")
        
        instance.getPromotionalOffer(for: ProductDiscountMock(), product: .mock()) { result in
            guard case .success = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertNotNil(mockPlugins[0].getPromotionalOfferCompletion)
        mockPlugins[0].getPromotionalOfferCompletion?(.notSupported)
        
        XCTAssertNotNil(mockPlugins[1].getPromotionalOfferCompletion)
        mockPlugins[1].getPromotionalOfferCompletion?(.notSupported)
        
        XCTAssertNotNil(mockPlugins[2].getPromotionalOfferCompletion)
        
        mockPlugins[2].getPromotionalOfferCompletion?(.success(PromoOfferMock()))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPromoOfferNotSupportedEverywhere() {
        let completionCalled = expectation(description: "Get promo offer completed 4")
        
        instance.getPromotionalOffer(for: ProductDiscountMock(), product: .mock()) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertNotNil(mockPlugins[0].getPromotionalOfferCompletion)
        mockPlugins[0].getPromotionalOfferCompletion?(.notSupported)
        
        XCTAssertNotNil(mockPlugins[1].getPromotionalOfferCompletion)
        mockPlugins[1].getPromotionalOfferCompletion?(.notSupported)
        
        XCTAssertNotNil(mockPlugins[2].getPromotionalOfferCompletion)
        
        mockPlugins[2].getPromotionalOfferCompletion?(.notSupported)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPurchaseFirstSuccess() {
        let completionCalled = expectation(description: "Get purchase completed 1")
        
        instance.purchase(.mock(), with: nil) { result in
            guard case .success(let purchase) = result else {
                return
            }
            
            XCTAssertEqual(purchase.transaction, .inApp)
            
            completionCalled.fulfill()
        }
        
        XCTAssertNotNil(mockPlugins[0].purchaseCompletion)
        XCTAssertNil(mockPlugins[1].purchaseCompletion)
        XCTAssertNil(mockPlugins[2].purchaseCompletion)
        
        mockPlugins[0].purchaseCompletion?(
            .success(SuccessfulPurchase(transaction: .inApp, paidFeatures: PaidFeatures()))
        )
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPurchaseFirstFail() {
        let completionCalled = expectation(description: "Get purchase completed 2")

        instance.purchase(.mock(), with: nil) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertNotNil(mockPlugins[0].purchaseCompletion)
        XCTAssertNil(mockPlugins[1].purchaseCompletion)
        XCTAssertNil(mockPlugins[2].purchaseCompletion)
        
        mockPlugins[0].purchaseCompletion?(.failure(NSError(domain: "", code: 0)))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPurchaseLastSuccess() {
        let completionCalled = expectation(description: "Get purchase completed 3")
        
        instance.purchase(.mock(), with: nil) { result in
            guard case .success(let purchase) = result else {
                return
            }
            
            XCTAssertEqual(purchase.transaction, .web)
            
            completionCalled.fulfill()
        }
        
        XCTAssertNotNil(mockPlugins[0].purchaseCompletion)
        mockPlugins[0].purchaseCompletion?(.notSupported)
        
        XCTAssertNotNil(mockPlugins[1].purchaseCompletion)
        mockPlugins[1].purchaseCompletion?(.notSupported)
        
        XCTAssertNotNil(mockPlugins[2].purchaseCompletion)
        
        mockPlugins[2].purchaseCompletion?(
            .success(SuccessfulPurchase(transaction: .web, paidFeatures: PaidFeatures()))
        )
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPurchaseNotSupportedEverywhere() {
        let completionCalled = expectation(description: "Get purchase completed 4")
        
        instance.purchase(.mock(), with: nil) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertNotNil(mockPlugins[0].purchaseCompletion)
        mockPlugins[0].purchaseCompletion?(.notSupported)
        
        XCTAssertNotNil(mockPlugins[1].purchaseCompletion)
        mockPlugins[1].purchaseCompletion?(.notSupported)
        
        XCTAssertNotNil(mockPlugins[2].purchaseCompletion)
        
        mockPlugins[2].purchaseCompletion?(.failure(NSError(domain: "", code: 0)))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testRestoreSuccess() {
        let pluginFeatures = [
            PaidFeatures(
                features: [
                    PaidFeature(name: "Feature 1", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                    PaidFeature(name: "Feature 2", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                    PaidFeature(name: "Feature 3", startDate: Date(timeIntervalSince1970: 0), endDate: nil)
                ]
            ),
            PaidFeatures(),
            PaidFeatures(
                features: [
                    PaidFeature(name: "Feature 6", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                    PaidFeature(name: "Feature 2", startDate: Date(timeIntervalSince1970: 88), endDate: nil),
                    PaidFeature(name: "Feature 5", startDate: Date(timeIntervalSince1970: 0), endDate: nil)
                ]
            )
        ]
        
        assert(mockPlugins.count == pluginFeatures.count)
        
        let expectedFeatures = PaidFeatures(
            features: [
                PaidFeature(name: "Feature 1", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                PaidFeature(name: "Feature 2", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                PaidFeature(name: "Feature 3", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                PaidFeature(name: "Feature 6", startDate: Date(timeIntervalSince1970: 0), endDate: nil),
                PaidFeature(name: "Feature 2", startDate: Date(timeIntervalSince1970: 88), endDate: nil),
                PaidFeature(name: "Feature 5", startDate: Date(timeIntervalSince1970: 0), endDate: nil)
            ]
        )
        
        let successCalled = expectation(description: "Restore successful")
        instance.restorePurchases {
            guard case .success(let features) = $0 else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            successCalled.fulfill()
        }
        
        DispatchQueue.concurrentPerform(iterations: pluginFeatures.count) { index in
            mockPlugins[index].restorePurchasesCompletion?(.success(pluginFeatures[index]))
        }
        
        mockPlugins.enumerated().forEach {
            XCTAssertNotNil($1.restorePurchasesCompletion)
        }
        
        wait(for: [successCalled], timeout: 0.1)
    }
    
    func testRestoreFailure() {
        let pluginFeatures = [
            PaidFeatures(),
            PaidFeatures()
        ]
        
        let failCalled = expectation(description: "Restore failure")
        instance.restorePurchases {
            guard case .failure = $0 else {
                return
            }
            
            failCalled.fulfill()
        }
        
        DispatchQueue.concurrentPerform(iterations: mockPlugins.count) { index in
            mockPlugins[index].restorePurchasesCompletion?(
                index != 2 ? .success(pluginFeatures[index]) : .failure(PaymentsError.unknownError)
            )
        }
        
        mockPlugins.enumerated().forEach {
            XCTAssertNotNil($1.restorePurchasesCompletion)
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testDelegateForwarded() {
        var callback: ((PurchasePluginResult<SuccessfulPurchase, Error>) -> Void)?
        mockPlugins[0].delegate?.purchasePlugin(mockPlugins[0], shouldPurchase: .mock()) {
            callback = $0
        }
        
        XCTAssertNotNil(delegateMock.product)
        
        let failCalled = expectation(description: "Fail called")
        delegateMock.callback? {
            guard case .failure = $0 else {
                return
            }
            
            failCalled.fulfill()
        }
        
        callback?(.notSupported)
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    private func checkPlugins(line: UInt = #line, file: StaticString = #file, _ check: (PurchasePluginMock) -> Bool) {
        XCTAssert(!mockPlugins.isEmpty, file: file, line: line)
        
        let checkResult = mockPlugins.allSatisfy(check)
        XCTAssert(checkResult, file: file, line: line)
    }
}
