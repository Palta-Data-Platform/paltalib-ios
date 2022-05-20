//
//  StoreProduct+Product.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation
import RevenueCat

struct RCProduct: Product {
    public var productType: ProductType {
        ProductType(rc: product.productType)
    }
    
    public var productIdentifier: String {
        product.productIdentifier
    }
    
    public var localizedDescription: String {
        product.localizedDescription
    }
    
    public var localizedTitle: String {
        product.localizedTitle
    }
    
    public var currencyCode: String? {
        product.currencyCode
    }
    
    public var price: Decimal {
        product.price
    }
    
    @available(iOS 11.2, *)
    public var subscriptionPeriod: SubscriptionPeriod? {
        product.subscriptionPeriod.map {
            SubscriptionPeriod(
                value: $0.value,
                unit: SubscriptionPeriod.Unit(rc: $0.unit)
            )
        }
    }
    
    @available(iOS 11.2, *)
    public var introductoryDiscount: ProductDiscount? {
        product.introductoryDiscount
    }
    
    @available(iOS 12.2, *)
    public var discounts: [ProductDiscount] {
        product.discounts as [ProductDiscount]
    }
    
    let product: StoreProduct
}

extension Product {
    var storeProduct: StoreProduct? {
        (self as? RCProduct)?.product
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
