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
            .mock(priority: 3, appStoreId: "0", ident: "i_0"),
            .mock(priority: 5, appStoreId: "1", ident: "i_1"),
            .mock(priority: 1, appStoreId: "2", ident: "i_2")
        ]
        
        showcaseService.result = .success(pricepoints)
        
        appStoreProductsService.result = .success([
            .mock(productIdentifier: pricepoints[0].productId),
            .mock(productIdentifier: pricepoints[1].productId),
            .mock(productIdentifier: pricepoints[2].productId)
        ])
        
        let successCalled = expectation(description: "Success called")
        
        flow.start { result in
            guard case let .success(products) = result else {
                return
            }
            
            XCTAssertEqual(
                products.map { $0.productIdentifier },
                [pricepoints[1].productId, pricepoints[0].productId, pricepoints[2].productId]
            )
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual(showcaseService.userId, userId)
        XCTAssertEqual(appStoreProductsService.ids, Set(pricepoints.map { $0.productId }))
        XCTAssertEqual(appStoreProductsService.idents, ["0": "i_0", "1": "i_1", "2": "i_2"])
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
