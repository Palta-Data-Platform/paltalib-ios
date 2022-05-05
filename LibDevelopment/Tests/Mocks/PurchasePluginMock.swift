//
//  PurchasePluginMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import PaltaLibPayments

final class PurchasePluginMock: PurchasePlugin {
    var logInUserId: String?
    var logOutCalled = false

    func logIn(appUserId: String) {
        logInUserId = appUserId
    }

    func logOut() {
        logOutCalled = true
    }
}

extension PurchasePluginMock: Equatable {
    static func ==(lhs: PurchasePluginMock, rhs: PurchasePluginMock) -> Bool {
        lhs === rhs
    }
}
