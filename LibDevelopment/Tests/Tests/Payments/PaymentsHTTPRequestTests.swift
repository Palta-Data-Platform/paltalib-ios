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
    func testGetShowcase() {
        let userId = UUID()
        let traceId = UUID()
        
        let request = PaymentsHTTPRequest(
            environment: .prod,
            traceId: traceId,
            endpoint: .getShowcase(.uuid(userId), nil)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader": "aValue"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "https://api.payments.paltabrain.com/showcase/get-price-points"))
        XCTAssertEqual(
            payloadString,
            "{\"requestContext\":{},\"customerId\":{\"value\":\"\(userId.uuidString)\",\"type\":\"merchant-uuid\"},\"storeType\":2}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "aHeader": "aValue",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
    
    func testGetSubscriptionsNoIDs() {
        let userIdString = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
        let traceId = UUID()
        
        let request = PaymentsHTTPRequest(
            environment: .dev,
            traceId: traceId,
            endpoint: .getSubcriptions(.uuid(UUID(uuidString: userIdString)!), nil)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader": "aValue"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "https://api.payments.dev.paltabrain.com/subscriptions-tracker/get-subscriptions"))
        XCTAssertEqual(
            payloadString,
            "{\"customerId\":{\"value\":\"\(userIdString.uppercased())\",\"type\":\"merchant-uuid\"}}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "aHeader": "aValue",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
    
    func testGetSubscriptionsWithIDs() {
        let userIdString = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
        let traceId = UUID()
        let subscriptionIDs: Set<UUID> = [UUID(), UUID()]
        
        let request = PaymentsHTTPRequest(
            environment: .prod,
            traceId: traceId,
            endpoint: .getSubcriptions(.uuid(UUID(uuidString: userIdString)!), subscriptionIDs)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader": "aValue"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }

        XCTAssert(payloadString!.contains("\"customerId\":"))
        XCTAssert(payloadString!.contains("\"onlyIds\":"))
    }
    
    func testGetFeatures() {
        let userIdString = "8900f862-0cc4-4d0a-aa12-5b76ea12c574"
        let traceId = UUID()
        
        let request = PaymentsHTTPRequest(
            environment: .prod,
            traceId: traceId,
            endpoint: .getFeatures(.uuid(UUID(uuidString: userIdString)!))
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader2": "aValue2"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "https://api.payments.paltabrain.com/feature-provisioner/get-features"))
        XCTAssertEqual(
            payloadString,
            "{\"customerId\":{\"value\":\"\(userIdString.uppercased())\",\"type\":\"merchant-uuid\"}}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "aHeader2": "aValue2",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
    
    func testStartCheckout() {
        let userId = UUID()
        let traceId = UUID()
        let orderId = UUID()
        
        let request = PaymentsHTTPRequest(
            environment: .dev,
            traceId: traceId,
            endpoint: .startCheckout(.uuid(userId), orderId)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader2": "aValue2"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "https://api.payments.dev.paltabrain.com/apple-store/start-checkout"))
        XCTAssertEqual(
            payloadString,
            "{\"orderId\":\"\(orderId.uuidString)\",\"customerId\":{\"value\":\"\(userId.uuidString)\",\"type\":\"merchant-uuid\"}}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "aHeader2": "aValue2",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
    
    func testCompleteCheckout() {
        let traceId = UUID()
        let orderId = UUID()
        let receipt = UUID().uuidString
        
        let request = PaymentsHTTPRequest(
            environment: .prod,
            traceId: traceId,
            endpoint: .checkoutCompleted(orderId, receipt)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader2": "aValue2"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "https://api.payments.paltabrain.com/apple-store/checkout-completed"))
        XCTAssertEqual(
            payloadString,
            "{\"orderId\":\"\(orderId.uuidString)\",\"receipt\":\"\(receipt)\"}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "aHeader2": "aValue2",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
}
