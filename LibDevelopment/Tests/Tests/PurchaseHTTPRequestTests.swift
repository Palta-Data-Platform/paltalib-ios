//
//  PurchaseHTTPRequestTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import XCTest
@testable import PaltaLibPayments

final class PurchaseHTTPRequestTests: XCTestCase {
    func testRestoreRequest() {
        let request = PurchaseHTTPRequest.restoreSubscription(
            RestoreRequestData(email: "anemail", webSubscriptionID: "subscription")
        )

        let expectedJSONString = "{\"email\":\"anemail\",\"web_subscription_id\":\"subscription\"}"
        let expectedHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "sampleHeader": "value"
        ]

        let urlRequest = request.urlRequest(headerFields: ["sampleHeader": "value"])
        let jsonString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }

        XCTAssertEqual(urlRequest?.url, URL(string: "https://ws.prod.paltabrain.com/v1/send-restore-subscription-email"))
        XCTAssertEqual(jsonString, expectedJSONString)
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
    }

    func testCancelRequest() {
        let request = PurchaseHTTPRequest.cancelSubscription(
            CancelRequestData(revenueCatID: "rev_cat", webSubscriptionID: "subscription")
        )

        let expectedJSONString = "{\"web_subscription_id\":\"subscription\",\"revenue_cat_id\":\"rev_cat\"}"
        let expectedHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "sampleHeader": "value"
        ]

        let urlRequest = request.urlRequest(headerFields: ["sampleHeader": "value"])
        let jsonString = urlRequest?.httpBody.flatMap { String(data: $0, encoding: .utf8) }

        XCTAssertEqual(urlRequest?.url, URL(string: "https://ws.prod.paltabrain.com/v1/unsubscribe"))
        XCTAssertEqual(jsonString, expectedJSONString)
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
    }
}
