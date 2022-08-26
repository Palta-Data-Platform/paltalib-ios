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
        let traceId = UUID()
        let expectedPricePoints = [
            PricePoint(ident: "ident1", parameters: .init(productId: "id1"), priority: 3),
            PricePoint(ident: "ident2", parameters: .init(productId: "id2"), priority: 5)
        ]
        
        let completionCalled = expectation(description: "Success called")
        
        httpMock.result = .success(
            ShowcaseResponse(
                status: "ok",
                pricePoints: expectedPricePoints
            )
        )
        
        service.getProductIds(for: .uuid(uuid), traceId: traceId) { result in
            guard case let .success(pricepoints) = result else {
                return
            }
            
            XCTAssertEqual(pricepoints, expectedPricePoints)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .getShowcase(.uuid(uuid), nil))
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.traceId, traceId)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testFail() {
        let uuid = UUID()
        let completionCalled = expectation(description: "Fail called")
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.urlError(URLError(.notConnectedToInternet)))
        
        service.getProductIds(for: .uuid(uuid), traceId: UUID()) { result in
            guard case let .failure(error) = result, case .networkError = error else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest)?.endpoint, .getShowcase(.uuid(uuid), nil))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testDevEnvironment() {
        service = ShowcaseServiceImpl(environment: .dev, httpClient: httpMock)
        
        service.getProductIds(for: .uuid(.init()), traceId: UUID()) { _ in }
        
        guard
            let request = httpMock.request as? PaymentsHTTPRequest
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(request.environment, .dev)
    }
    
    func testProdEnvironment() {
        service = ShowcaseServiceImpl(environment: .prod, httpClient: httpMock)
        
        service.getProductIds(for: .uuid(.init()), traceId: UUID()) { _ in }
        
        guard
            let request = httpMock.request as? PaymentsHTTPRequest
        else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(request.environment, .prod)
    }
}
