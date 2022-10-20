//
//  BatchSenderTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

import Foundation
import XCTest
import PaltaLibCore
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class BatchSenderTests: XCTestCase {
    private var httpMock: HTTPClientMock!
    
    private var sender: BatchSenderImpl!
    
    private let apiToken = "MOCK_API_TOKEN"
    private let url = URL(string: "fake://url.com")
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        httpMock = .init()
        
        sender = BatchSenderImpl(httpClient: httpMock)
        
        sender.apiToken = apiToken
        sender.baseURL = url
    }
    
    func testTokenPassed() {
        XCTAssertEqual(httpMock.mandatoryHeaders, ["X-API-Key": apiToken])
    }
    
    func testSuccess() {
        let successCalled = expectation(description: "Success called")
        let batch = Batch.mock()
        
        httpMock.result = .success(EmptyResponse())
        
        sender.sendBatch(batch) { result in
            guard case .success = result else {
                return
            }
            
            successCalled.fulfill()
        }
        
        let request = httpMock.request as? AnalyticsHTTPRequest
        
        XCTAssertNotNil(request)
        
        guard case let .sendEvents(url, payload) = request else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(url, self.url)
        XCTAssertEqual(payload.serviceInfo.telemetry, batch.telemetry)
        XCTAssertEqual(payload.events, batch.events)
        
        wait(for: [successCalled], timeout: 0.1)
    }
    
    func testFailNoInternet() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch.mock()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.urlError(URLError(.notConnectedToInternet)))
        
        sender.sendBatch(batch) { result in
            guard case .failure(let error) = result, case .noInternet = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testFailTimeout() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch.mock()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.urlError(URLError(.timedOut)))
        
        sender.sendBatch(batch) { result in
            guard case .failure(let error) = result, case .timeout = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testFailServerError() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch.mock()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.invalidStatusCode(502, nil))
        
        sender.sendBatch(batch) { result in
            guard case .failure(let error) = result, case .serverError = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testFailClientError() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch.mock()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.invalidStatusCode(401, nil))
        
        sender.sendBatch(batch) { result in
            guard case .failure(let error) = result, case .unknown = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
    
    func testFailOtherError() {
        let failCalled = expectation(description: "Fail called")
        let batch = Batch.mock()
        
        httpMock.result = .failure(NetworkErrorWithoutResponse.other(NSError(domain: "", code: 0)))
        
        sender.sendBatch(batch) { result in
            guard case .failure(let error) = result, case .unknown = error else {
                return
            }
            
            failCalled.fulfill()
        }
        
        wait(for: [failCalled], timeout: 0.1)
    }
}
