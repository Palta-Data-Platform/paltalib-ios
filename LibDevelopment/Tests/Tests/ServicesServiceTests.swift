//
//  ServicesServiceTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class ServicesServiceTests: XCTestCase {
    var service: ServicesServiceImpl!
    var httpMock: HTTPClientMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        httpMock = .init()
        service = .init(httpClient: httpMock)
    }
    
    func testSuccess() {
        let uuid = UUID()
        let expectedServices = [Service.mock()]
        let completionCalled = expectation(description: "Success called")
        
        httpMock.result = .success(ServiceResponse(services: expectedServices))
        
        service.getServices(for: .uuid(uuid)) { result in
            guard case let .success(services) = result else {
                return
            }
            
            XCTAssertEqual(services, expectedServices)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest), .getServices(.uuid(uuid)))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testFail() {
        let uuid = UUID()
        let expectedServices = [Service.mock()]
        let completionCalled = expectation(description: "Fail called")
        
        httpMock.result = .success(ServiceResponse(services: expectedServices))
        
        service.getServices(for: .uuid(uuid)) { result in
            guard case let .success(services) = result else {
                return
            }
            
            XCTAssertEqual(services, expectedServices)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest), .getServices(.uuid(uuid)))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
