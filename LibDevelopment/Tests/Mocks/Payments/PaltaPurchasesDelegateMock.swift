//
//  PaltaPurchasesDelegateMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 08/06/2022.
//

import Foundation
import PaltaLibPayments

final class PaltaPurchasesDelegateMock: PaltaPurchasesDelegate {
    var product: Product?
    var callback: DefermentCallback?
    
    func purchases(
        _ purchases: PaltaPurchases,
        shouldPurchase promoProduct: Product,
        defermentCallback: @escaping DefermentCallback
    ) {
        self.product = promoProduct
        self.callback = defermentCallback
    }
}
