//
//  PurchasesAssembly.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation
import Purchases
import PaltaLibAttribution
import PaltaLibCore

final class PurchasesAssembly {
    private let coreAssembly = CoreAssembly()

    private(set) lazy var purchasesInstance = PaltaPurchases(
        purchases: Purchases.shared,
        appsflyerAdapter: PaltaAppsflyerAdapter.sharedInstance,
        httpClient: coreAssembly.httpClient
    )
}
