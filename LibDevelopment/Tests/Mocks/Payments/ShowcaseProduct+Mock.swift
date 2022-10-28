//
//  ShowcaseProduct+Mock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 28/09/2022.
//

import Foundation
import StoreKit
@testable import PaltaLibPayments

extension ShowcaseProduct {
    static func mock(ident: String = UUID().uuidString, productIdentifier: String = UUID().uuidString) -> ShowcaseProduct {
        let skProduct = SKProduct()
        skProduct.setValue(productIdentifier, forKey: "productIdentifier")
        
        return ShowcaseProduct(
            ident: ident,
            skProduct: skProduct
        )
    }
}
