//
//  ShowcaseResponseTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class ShowcaseResponseTests: XCTestCase {
    func testDecode() throws {
        let data = """
{
  "status": "success",
  "pricePoints": [
    {
      "ident": "ident1",
      "priority": 1001,
      "appleStore": {
          "productId": "id1"
      }
    },
    {
      "ident": "ident2",
      "appleStore": {
          "productId": "id2"
      }
    }
  ]
}
""".data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ShowcaseResponse.self, from: data)
        
        XCTAssertEqual(response.status, "success")
        XCTAssertEqual(response.pricePoints.count, 2)
        XCTAssertEqual(response.pricePoints.first?.ident, "ident1")
        XCTAssertEqual(response.pricePoints.last?.productId, "id2")
        XCTAssertEqual(response.pricePoints.first?.priority, 1001)
        XCTAssertEqual(response.pricePoints.last?.priority, nil)
    }
    
    func testDecodeFaultyPricePoint() throws {
        let data = """
{
  "status": "success",
  "pricePoints": [
    {
      "ident": "ident1",
      "priority": 1001,
      "appleStore": {
          "productId": "id1"
      }
    },
    {
      "ident": "ident-1",
      "priority": 58
    },
    {
      "ident": "ident2",
      "appleStore": {
          "productId": "id2"
      }
    },
    {
      "appleStore": {
          "productId": "id12"
      }
    }
  ]
}
""".data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ShowcaseResponse.self, from: data)
        
        XCTAssertEqual(response.status, "success")
        XCTAssertEqual(response.pricePoints.count, 2)
        XCTAssertEqual(response.pricePoints.first?.ident, "ident1")
        XCTAssertEqual(response.pricePoints.last?.productId, "id2")
        XCTAssertEqual(response.pricePoints.first?.priority, 1001)
        XCTAssertEqual(response.pricePoints.last?.priority, nil)
    }
}
