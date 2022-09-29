//
//  ProductMock.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import Foundation
@testable import PaltaLibPayments

extension Product {
    static func mock(productIdentifier: String = "") -> Product {
        .init(
            productType: .nonRenewableSubscription,
            productIdentifier: productIdentifier,
            localizedDescription: "",
            localizedTitle: "",
            currencyCode: nil,
            price: 0,
            localizedPriceString: "",
            subscriptionPeriod: nil,
            introductoryDiscount: nil,
            discounts: [],
            originalEntity: 0
        )
    }
}
