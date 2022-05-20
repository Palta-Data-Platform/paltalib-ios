//
//  ServiceResponseTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class ServiceResponseTests: XCTestCase {
    func testDecode() throws {
        let data = """
{
  "status": "success",
  "services": [
    {
      "quantity": 234,
      "actualFrom": "2022-05-20T08:22:05.217Z",
      "actualTill": "2022-06-20T08:22:05.217Z",
      "sku": "sku-1"
    }
  ]
}
""".data(using: .utf8)!

        let response = try JSONDecoder.default.decode(ServiceResponse.self, from: data)
        
        XCTAssertEqual(response.services.first?.quantity, 234)
        XCTAssertEqual(response.services.first?.sku, "sku-1")
        
        XCTAssertEqual(
            response.services.first?.actualFrom,
            Date(timeIntervalSince1970: 1653034925.217)
        )
        
        XCTAssertEqual(
            response.services.first?.actualTill,
            Date(timeIntervalSince1970: 1655713325.217)
        )
    }
}
