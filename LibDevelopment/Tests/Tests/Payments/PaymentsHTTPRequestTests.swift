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
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest.getSubcriptions(
            env,
            .uuid(UUID(uuidString: userIdString)!),
            nil
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader": "aValue"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, env.appendingPathComponent("subscriptions-tracker/get-subscriptions"))
        XCTAssertEqual(
            payloadString,
            "{\"customerId\":{\"value\":\"\(userIdString.uppercased())\",\"type\":\"merchant-uuid\"}}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            ["Content-Type": "application/json", "aHeader": "aValue"]
        )
    }
    
    func testGetSubscriptionsWithIDs() {
        let userIdString = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
        let subscriptionIDs: Set<UUID> = [UUID(), UUID()]
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest.getSubcriptions(
            env,
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
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest.getFeatures(
            env,
            .uuid(UUID(uuidString: userIdString)!)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader2": "aValue2"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, env.appendingPathComponent("feature-provisioner/get-features"))
        XCTAssertEqual(
            payloadString,
            "{\"customerId\":{\"value\":\"\(userIdString.uppercased())\",\"type\":\"merchant-uuid\"}}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            ["Content-Type": "application/json", "aHeader2": "aValue2"]
        )
    }
}
