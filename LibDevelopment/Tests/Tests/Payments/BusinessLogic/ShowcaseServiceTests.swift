//
//  ShowcaseServiceTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import Foundation
import PaltaLibCore
import XCTest
@testable import PaltaLibPayments

final class ShowcaseServiceTests: XCTestCase {
    var service: ShowcaseServiceImpl!
    var httpMock: HTTPClientMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        httpMock = .init()
        service = .init(environment: .dev, httpClient: httpMock)
    }
    
    func testSuccess() {
        let uuid = UUID()
        let expectedProductIds: Set<String> = ["id1", "id2"]
        let completionCalled = expectation(description: "Success called")
        
        httpMock.result = .success(
            ShowcaseResponse(
                status: "ok",
                pricePoints: [
                    PricePoint(ident: "ident1", appStoreId: "id1"),
                    PricePoint(ident: "ident2", appStoreId: "id2")
                ]
            )
        )
        
        service.getProductIds(for: .uuid(uuid)) { result in
            guard case let .success(productIds) = result else {
                return
            }
            
            XCTAssertEqual(productIds, expectedProductIds)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest), .getShowcase(.dev, .uuid(uuid), nil))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testFail() {
        let uuid = UUID()
        let completionCalled = expectation(description: "Fail called")
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.urlError(URLError(.notConnectedToInternet)))
        
        service.getProductIds(for: .uuid(uuid)) { result in
            guard case let .failure(error) = result, case .networkError = error else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest), .getShowcase(.dev, .uuid(uuid), nil))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testDevEnvironment() {
        service = ShowcaseServiceImpl(environment: .dev, httpClient: httpMock)
        
        service.getProductIds(for: .uuid(.init())) { _ in }
        
        guard
            let request = httpMock.request as? PaymentsHTTPRequest,
                case let .getShowcase(env, _, _) = request
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(env, .dev)
    }
    
    func testProdEnvironment() {
        service = ShowcaseServiceImpl(environment: .prod, httpClient: httpMock)
        
        service.getProductIds(for: .uuid(.init())) { _ in }
        
        guard
            let request = httpMock.request as? PaymentsHTTPRequest,
                case let .getShowcase(env, _, _) = request
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(env, .prod)
    }
}
