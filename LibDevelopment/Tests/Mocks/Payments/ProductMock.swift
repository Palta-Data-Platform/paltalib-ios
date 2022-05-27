//
//  ProductMock.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import Foundation
import PaltaLibPayments

struct ProductMock: Product {
    var productType: ProductType = .nonRenewableSubscription
    var productIdentifier: String = ""
    var localizedDescription: String = ""
    var localizedTitle: String = ""
    var currencyCode: String?
    var price: Decimal = 0
    var subscriptionPeriod: SubscriptionPeriod?
    var introductoryDiscount: ProductDiscount?
    var discounts: [ProductDiscount] = []
}
