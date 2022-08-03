//
//  FeatureResponseTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class FeatureResponseTests: XCTestCase {
    func testDecode() throws {
        let data = """
{
  "status": "success",
  "features": [
    {
      "quantity": 234,
      "actualFrom": "2022-03-27T08:14:56.217000+00:00",
      "actualTill": "2022-04-27T08:14:56.217000+00:00",
      "lastSubscriptionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "feature": "sku-1"
    }
  ]
}
""".data(using: .utf8)!

        let response = try JSONDecoder.default.decode(FeaturesResponse.self, from: data)
        
        XCTAssertEqual(response.features.first?.quantity, 234)
        XCTAssertEqual(response.features.first?.feature, "sku-1")
        
        XCTAssertEqual(
            response.features.first?.actualFrom,
            Date(timeIntervalSince1970: 1648368896.217)
        )
        
        XCTAssertEqual(
            response.features.first?.actualTill,
            Date(timeIntervalSince1970: 1651047296.217)
        )
        
        XCTAssertEqual(
            response.features.first?.lastSubscriptionId,
            UUID(uuidString: "3fa85f64-5717-4562-b3fc-2c963f66afa6")!
        )
    }
    
    func testDecodeNoSubscriptionId() throws {
        let data = """
{
  "status": "success",
  "features": [
    {
      "quantity": 234,
      "actualFrom": "2022-03-27T08:14:56.217000+00:00",
      "actualTill": "2022-04-27T08:14:56.217000+00:00",
      "feature": "sku-1"
    }
  ]
}
""".data(using: .utf8)!

        let response = try JSONDecoder.default.decode(FeaturesResponse.self, from: data)
        
        XCTAssertNil(response.features.first?.lastSubscriptionId)
    }
}
