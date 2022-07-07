//
//  SDKInfoProviderTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 16/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class SDKInfoProviderTests: XCTestCase {
    func testName() {
        XCTAssertEqual(SDKInfoProviderImpl().sdkName, "PALTABRAIN_IOS")
    }
    
    func testVersion() {
        XCTAssertEqual(SDKInfoProviderImpl().sdkVersion, "1.0")
    }
}
