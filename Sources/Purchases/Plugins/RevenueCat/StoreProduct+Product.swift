//
//  StoreProduct+Product.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation
import RevenueCat

extension Product {
    init(rc: StoreProduct) {
        self.init(
            productType: ProductType(rc: rc.productType),
            productIdentifier: rc.productIdentifier,
            localizedDescription: rc.localizedDescription,
            localizedTitle: rc.localizedTitle,
            currencyCode: rc.currencyCode,
            price: rc.price,
            localizedPriceString: rc.localizedPriceString,
            subscriptionPeriod: rc._subscriptionPeriod,
            introductoryDiscount: rc._introductoryDiscount,
            discounts: rc._discounts,
            originalEntity: rc
        )
    }
    
    var storeProduct: StoreProduct? {
        originalEntity as? StoreProduct
    }
}

private extension StoreProduct {
    var _subscriptionPeriod: SubscriptionPeriod? {
        subscriptionPeriod.map {
            SubscriptionPeriod(rc: $0)
        }
    }
    
    var _introductoryDiscount: ProductDiscount? {
        introductoryDiscount.map(ProductDiscount.init)
    }
}

private extension StoreProduct {
    var _discounts: [ProductDiscount] {
        discounts.map(ProductDiscount.init)
    }
}

private extension ProductType {
    init(rc: StoreProduct.ProductType) {
        switch rc {
        case .autoRenewableSubscription:
            self = .autoRenewableSubscription
            
        case .consumable:
            self = .consumable
            
        case .nonConsumable:
            self = .nonConsumable
            
        case .nonRenewableSubscription:
            self = .nonRenewableSubscription
        }
    }
}

private extension SubscriptionPeriod.Unit {
    init(rc: RevenueCat.SubscriptionPeriod.Unit) {
        switch rc {
        case .month:
            self = .month
            
        case .year:
            self = .year
            
        case .week:
            self = .week
            
        case .day:
            self = .day
        }
    }
}

extension SubscriptionPeriod {
    init(rc: RevenueCat.SubscriptionPeriod) {
        self.init(value: rc.value, unit: Unit(rc: rc.unit))
    }
}
