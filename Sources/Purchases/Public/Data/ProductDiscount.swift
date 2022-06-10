//
//  ProductDiscount.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 08.05.2022.
//

import Foundation

public struct ProductDiscount {
    public let offerIdentifier: String?
    public let currencyCode: String?
    public let price: Decimal
    public let numberOfPeriods: Int
    public let subscriptionPeriod: SubscriptionPeriod
    public let localizedPriceString: String
    
    let originalEntity: Any
}

extension ProductDiscount: Hashable {
    public static func == (lhs: ProductDiscount, rhs: ProductDiscount) -> Bool {
        lhs.offerIdentifier == rhs.offerIdentifier
        && lhs.currencyCode == rhs.currencyCode
        && lhs.price == rhs.price
        && lhs.numberOfPeriods == rhs.numberOfPeriods
        && lhs.subscriptionPeriod == rhs.subscriptionPeriod
    }
    
    public func hash(into hasher: inout Hasher) {
        offerIdentifier.hash(into: &hasher)
        currencyCode.hash(into: &hasher)
        price.hash(into: &hasher)
        numberOfPeriods.hash(into: &hasher)
        subscriptionPeriod.hash(into: &hasher)
    }
}
