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
            guard case .notSupported = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetOffer() {
        let completionCalled = expectation(description: "Not supported called")
        
        plugin.getPromotionalOffer(for: ProductDiscountMock(), product: ProductMock()) { result in
            guard case .notSupported = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPurchase() {
        let completionCalled = expectation(description: "Not supported called")
        
        plugin.purchase(ProductMock(), with: nil) { result in
            guard case .notSupported = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
