//
//  PaymentsHTTPRequestTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class PaymentsHTTPRequestTests: XCTestCase {
    func testGetSubscriptionsNoIDs() {
        let userIdString = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
        
        let request = PaymentsHTTPRequest.getSubcriptions(
            .uuid(UUID(uuidString: userIdString)!),
            nil
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader": "aValue"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "https://a.com/subscriptions-tracker/get-subscriptions"))
        XCTAssertEqual(
            payloadString,
            "{\"customerId\":{\"value\":\"\(userIdString.uppercased())\",\"type\":\"merchant-uuid\"}}"
        )
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, ["aHeader": "aValue"])
    }
    
    func testGetSubscriptionsWithIDs() {
        let userIdString = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
        let subscriptionIDs: Set<UUID> = [UUID(), UUID()]
        
        let request = PaymentsHTTPRequest.getSubcriptions(
            .uuid(UUID(uuidString: userIdString)!),
            subscriptionIDs
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader": "aValue"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }

        XCTAssert(payloadString!.contains("\"customerId\":"))
        XCTAssert(payloadString!.contains("\"onlyIds\":"))
    }
    
    func testGetFeatures() {
        let userIdString = "8900f862-0cc4-4d0a-aa12-5b76ea12c574"
        
        let request = PaymentsHTTPRequest.getFeatures(
            .uuid(UUID(uuidString: userIdString)!)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader2": "aValue2"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "https://a.com/service-provisioner/get-services"))
        XCTAssertEqual(
            payloadString,
            "{\"customerId\":{\"value\":\"\(userIdString.uppercased())\",\"type\":\"merchant-uuid\"}}"
        )
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, ["aHeader2": "aValue2"])
    }
}
