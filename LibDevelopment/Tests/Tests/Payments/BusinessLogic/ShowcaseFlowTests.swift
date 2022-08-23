//
//  ShowcaseFlowTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 22/08/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class ShowcaseFlowTests: XCTestCase {
    private var flow: ShowcaseFlowImpl!
    
    private var userId: UserId!
    private var showcaseService: ShowcaseServiceMock!
    private var appStoreProductsService: AppstoreProductServiceMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        userId = .uuid(.init())
        showcaseService = .init()
        appStoreProductsService = .init()
        
        flow = .init(userId: userId, showcaseService: showcaseService, appStoreProductsService: appStoreProductsService)
    }
    
    func testSuccess() {
        let pricepoints: [PricePoint] = [
            .mock(priority: 3),
            .mock(priority: 5),
            .mock(priority: 1)
        ]
        
        showcaseService.result = .success(pricepoints)
        
        appStoreProductsService.result = .success([
            .mock(productIdentifier: pricepoints[0].appStoreId),
            .mock(productIdentifier: pricepoints[1].appStoreId),
            .mock(productIdentifier: pricepoints[2].appStoreId)
        ])
        
        let successCalled = expectation(description: "Success called")
        
        flow.start { result in
            guard case let .success(products) = result else {
                return
            }
            
            XCTAssertEqual(
                products.map { $0.productIdentifier },
                [pricepoints[1].appStoreId, pricepoints[0].appStoreId, pricepoints[2].appStoreId]
            )
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual(showcaseService.userId, userId)
        XCTAssertEqual(appStoreProductsService.ids, Set(pricepoints.map { $0.appStoreId }))
    }
    
    func testFailShowcase() {
        showcaseService.result = .failure(.timedOut)
        
        appStoreProductsService.result = .success([])
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case let .failure(error) = result, case .timedOut = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(showcaseService.userId, userId)
        XCTAssertNil(appStoreProductsService.ids)
    }
    
    func testFailAppstore() {
        showcaseService.result = .success([.mock()])
        
        appStoreProductsService.result = .failure(.invalidKey)
        
        let failCalled = expectation(description: "Fail called")
        
        flow.start { result in
            guard case let .failure(error) = result, case .invalidKey = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
        
        XCTAssertEqual(showcaseService.userId, userId)
        XCTAssertNotNil(appStoreProductsService.ids)
    }
}
