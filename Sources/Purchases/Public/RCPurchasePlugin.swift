//
//  RCPurchasePlugin.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import RevenueCat

public final class RCPurchasePlugin: PurchasePlugin {
    private let purchases = Purchases.shared

    public func logIn(appUserId: String) {
        purchases.logIn(appUserId, completion: { _, _, _ in })
    }

    public func logOut() {
        purchases.logOut(completion: nil)
    }
}
