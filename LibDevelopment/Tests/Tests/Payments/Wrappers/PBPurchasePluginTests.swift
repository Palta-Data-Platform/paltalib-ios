//
//  PBPurchasePluginTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class PBPurchasePluginTests: XCTestCase {
    var assemblyMock: PaymentsAssemblyMock!
    
    var plugin: PBPurchasePlugin!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        assemblyMock = .init()
        
        plugin = PBPurchasePlugin(assembly: assemblyMock)
    }
    
    func testLogInLogOut() {
        let userId = UserId.uuid(UUID())
        let successCalled = expectation(description: "Success called")
        
        plugin.logIn(appUserId: userId) {
            guard case .success = $0 else {
                return
            }
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual(plugin.userId, userId)
        
        plugin.logOut()
        
        XCTAssertNil(plugin.userId)
    }
    
    func testGetPaidServicesSuccess() {
        let userId = UserId.uuid(UUID())
        let expectedFeatures = PaidFeatures(features: [.init(name: "name", startDate: Date())])
        assemblyMock.paidFeaturesMock.result = .success(expectedFeatures)
        
        let completionCalled = expectation(description: "Success called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getPaidFeatures { result in
            guard case let .success(features) = result else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.paidFeaturesMock.userId, userId)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetPaidServicesFail() {
        let userId = UserId.uuid(UUID())
        assemblyMock.paidFeaturesMock.result = .failure(.invalidKey)
        
        let completionCalled = expectation(description: "Fail called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getPaidFeatures { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.paidFeaturesMock.userId, userId)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetPaidServicesNoLogin() {
        let completionCalled = expectation(description: "Fail called")
        
        plugin.getPaidFeatures { result in
            guard case let .failure(error) = result, case .noUserId = (error as? PaymentsError) else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetProducts() {
        let completionCalled = expectation(description: "Not supported called")
        
        plugin.getProducts(with: []) { result in
            guard case .success(let products) = result else {
                return
            }
            
            XCTAssert(products.isEmpty)
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetShowcaseProductsSuccess() {
        let productId = UUID().uuidString
        let userId = UserId.uuid(.init())
        let completionCalled = expectation(description: "Success called")
        
        assemblyMock.showcaseFlowMock.result = .success([.mock(productIdentifier: productId)])
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        
        plugin.getShowcaseProducts { result in
            guard case .success(let products) = result else {
                return
            }
            
            XCTAssertEqual(products.count, 1)
            XCTAssertEqual(products.first?.productIdentifier, productId)
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
        
        XCTAssertEqual(assemblyMock.showcaseUserId, userId)
    }
    
    func testGetShowcaseProductsFail() {
        let userId = UserId.uuid(.init())
        let completionCalled = expectation(description: "Fail called")
        
        assemblyMock.showcaseFlowMock.result = .failure(.timedOut)
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        
        plugin.getShowcaseProducts { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
        
        XCTAssertEqual(assemblyMock.showcaseUserId, userId)
    }
    
    func testGetShowcaseProductsNoUserId() {
        let completionCalled = expectation(description: "Fail called")
        
        plugin.getShowcaseProducts { result in
            guard
                case .failure(let error) = result,
                let paymentsError = error as? PaymentsError,
                    case .noUserId = paymentsError
            else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetOffer() {
        let completionCalled = expectation(description: "Not supported called")
        
        plugin.getPromotionalOffer(for: .mock(), product: .mock()) { result in
            guard case .notSupported = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPurchaseSuccess() {
        let userId = UserId.uuid(UUID())
        plugin.logIn(appUserId: userId, completion: { _ in })
        
        let product = Product.mock()
        assemblyMock.checkoutFlowMock.result = .success(PaidFeatures())
        let completionCalled = expectation(description: "Not supported called")
        
        plugin.purchase(product, with: nil) { result in
            guard case .success = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.checkoutUserId, userId)
        XCTAssertEqual(assemblyMock.checkoutProduct, product.originalEntity as? ShowcaseProduct)
        XCTAssertNotNil(assemblyMock.checkoutProduct)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
