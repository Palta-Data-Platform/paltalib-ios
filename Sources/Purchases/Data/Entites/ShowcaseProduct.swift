//
//  ShowcaseProduct.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 27/09/2022.
//

import Foundation
import StoreKit

struct ShowcaseProduct: Equatable {
    let ident: String
    let skProduct: SKProduct
    let discount: SKProductDiscount?
    let priority: Int?
}
