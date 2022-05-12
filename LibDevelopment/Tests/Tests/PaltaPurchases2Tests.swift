//
//  PaltaPurchases2Tests.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import XCTest
@testable import PaltaLibPayments

final class PaltaPurchases2Tests: XCTestCase {
    var instance: PaltaPurchases2!
    var mockPlugins: [PurchasePluginMock] = []
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockPlugins = (1...2).map { _ in PurchasePluginMock() }
        instance = PaltaPurchases2()
        instance.setup(with: mockPlugins)
    }
    
    func testConfigure() {
        let plugins = (1...3).map { _ in PurchasePluginMock() }
        let instance = PaltaPurchases2()
        instance.setup(with: plugins)

        XCTAssert(instance.setupFinished)
        XCTAssertEqual(instance.plugins as? [PurchasePluginMock], plugins)
    }
    
    func testLogin() {
        let userId = UUID().uuidString
        
        instance.logIn(appUserId: userId)
        
        checkPlugins {
            $0.logInUserId == userId
        }
    }
    
    private func checkPlugins(line: UInt = #line, file: StaticString = #file, _ check: (PurchasePluginMock) -> Bool) {
        XCTAssert(!mockPlugins.isEmpty, file: file, line: line)
        
        let checkResult = mockPlugins.allSatisfy(check)
        XCTAssert(checkResult, file: file, line: line)
    }
}
