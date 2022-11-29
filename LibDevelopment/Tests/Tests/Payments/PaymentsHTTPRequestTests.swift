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
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest(
            environment: env,
            traceId: traceId,
            endpoint: .getShowcase(.uuid(userId), nil)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader": "aValue"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "\(env)/showcase/get-price-points"))
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
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest(
            environment: env,
            traceId: traceId,
            endpoint: .getSubcriptions(.uuid(UUID(uuidString: userIdString)!), nil)
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
        let env = URL(string: "http://\(UUID())")!

        let request = PaymentsHTTPRequest(
            environment: env,
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
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest(
            environment: env,
            traceId: traceId,
            endpoint: .getFeatures(.uuid(UUID(uuidString: userIdString)!))
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
            [
                "Content-Type": "application/json",
                "aHeader2": "aValue2",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
    
    func testStartCheckout() {
        let userId = UUID()
        let ident = UUID().uuidString
        let traceId = UUID()
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest(
            environment: env,
            traceId: traceId,
            endpoint: .startCheckout(.uuid(userId), ident)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader2": "aValue2"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "\(env)/apple-store/start-checkout"))
        XCTAssertEqual(
            payloadString,
            "{\"ident\":\"\(ident)\",\"customerId\":{\"value\":\"\(userId.uuidString)\",\"type\":\"merchant-uuid\"}}"
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
        let transactionId = UUID().uuidString
        let originalTransactionId = UUID().uuidString
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest(
            environment: env,
            traceId: traceId,
            endpoint: .checkoutCompleted(orderId, receipt, transactionId, originalTransactionId)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader2": "aValue2"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "\(env)/apple-store/checkout-completed"))
        XCTAssertEqual(
            payloadString,
            "{\"orderId\":\"\(orderId.uuidString)\",\"purchase\":{\"originalTransactionId\":\"\(originalTransactionId)\",\"receiptData\":\"\(receipt)\",\"transactionId\":\"\(transactionId)\"}}"
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
    
    func testFailCheckout() {
        let traceId = UUID()
        let orderId = UUID()
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest(
            environment: env,
            traceId: traceId,
            endpoint: .checkoutFailed(orderId, 585, "Some message")
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader5": "aValue5"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "\(env)/apple-store/checkout-failed"))
        XCTAssertEqual(
            payloadString,
            "{\"orderId\":\"\(orderId.uuidString)\",\"purchase\":{\"errorMessage\":\"Some message\",\"errorCode\":\"585\"}}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "aHeader5": "aValue5",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
    
    func testGetCheckout() {
        let traceId = UUID()
        let orderId = UUID()
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest(
            environment: env,
            traceId: traceId,
            endpoint: .getCheckout(orderId)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader5": "aValue5"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "\(env)/apple-store/get-checkout"))
        XCTAssertEqual(
            payloadString,
            "{\"orderId\":\"\(orderId.uuidString)\"}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "aHeader5": "aValue5",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
    
    func testRestore() {
        let traceId = UUID()
        let customerId = UserId.string("a customer")
        let receipt = "a receipt"
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest(
            environment: env,
            traceId: traceId,
            endpoint: .restorePurchase(customerId, receipt)
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader5": "aValue5"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "\(env)/apple-store/process-restore"))
        XCTAssertEqual(
            payloadString,
            "{\"customerId\":{\"value\":\"a customer\",\"type\":\"merchant-str\"},\"receiptData\":\"a receipt\"}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "aHeader5": "aValue5",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
    
    func testLog() {
        let traceId = UUID()
        let env = URL(string: "http://\(UUID())")!
        
        let request = PaymentsHTTPRequest(
            environment: env,
            traceId: traceId,
            endpoint: .log(.error, "An event", ["3": 5])
        )
        
        let urlRequest = request.urlRequest(headerFields: ["aHeader5": "aValue5"])
        let payloadString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.url, URL(string: "\(env)/apple-store/log-event"))
        XCTAssertEqual(
            payloadString,
            "{\"level\":\"error\",\"eventName\":\"An event\",\"data\":{\"3\":5}}"
        )
        XCTAssertEqual(
            urlRequest?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "aHeader5": "aValue5",
                "x-paltabrain-trace-id": traceId.uuidString
            ]
        )
    }
}
