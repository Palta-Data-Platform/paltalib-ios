//
//  Product.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 08.05.2022.
//

import Foundation

public enum ProductType: Hashable {
    /// A consumable in-app purchase.
    case consumable

    /// A non-consumable in-app purchase.
    case nonConsumable

    /// A non-renewing subscription.
    case nonRenewableSubscription

    /// An auto-renewable subscription.
    case autoRenewableSubscription

}

public struct SubscriptionPeriod: Hashable {
    public enum Unit: Int, Hashable {
        /// A subscription period unit of a day.
        case day = 0
        /// A subscription period unit of a week.
        case week = 1
        /// A subscription period unit of a month.
        case month = 2
        /// A subscription period unit of a year.
        case year = 3
    }

    /// The number of period units.
    public let value: Int
    /// The increment of time that a subscription period is specified in.
    public let unit: Unit
}

public struct Product {
    public let productType: ProductType
    public let productIdentifier: String
    public let localizedDescription: String
    public let localizedTitle: String
    public let currencyCode: String?
    public let price: Decimal
    
    let originalEntity: Any
    
    private let _subscriptionPeriod: Any?
    private let _introductoryDiscount: Any?
    private let _discounts: Any?

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    public var subscriptionPeriod: SubscriptionPeriod? {
        _subscriptionPeriod as? SubscriptionPeriod
    }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    public var introductoryDiscount: ProductDiscount? {
        _introductoryDiscount as? ProductDiscount
    }

    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, watchOS 6.2, *)
    public var discounts: [ProductDiscount] {
        _discounts as? [ProductDiscount] ?? []
    }
}

extension Product {
    init(
        productType: ProductType,
        productIdentifier: String,
        localizedDescription: String,
        localizedTitle: String,
        currencyCode: String?,
        price: Decimal,
        originalEntity: Any
    ) {
        self.productType = productType
        self.productIdentifier = productIdentifier
        self.localizedDescription = localizedDescription
        self.localizedTitle = localizedTitle
        self.currencyCode = currencyCode
        self.price = price
        self._subscriptionPeriod = nil
        self._introductoryDiscount = nil
        self._discounts = nil
        self.originalEntity = originalEntity
    }
    
    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    init(
        productType: ProductType,
        productIdentifier: String,
        localizedDescription: String,
        localizedTitle: String,
        currencyCode: String?,
        price: Decimal,
        subscriptionPeriod: SubscriptionPeriod?,
        introductoryDiscount: ProductDiscount?,
        originalEntity: Any
    ) {
        self.productType = productType
        self.productIdentifier = productIdentifier
        self.localizedDescription = localizedDescription
        self.localizedTitle = localizedTitle
        self.currencyCode = currencyCode
        self.price = price
        self._subscriptionPeriod = subscriptionPeriod
        self._introductoryDiscount = introductoryDiscount
        self._discounts = nil
        self.originalEntity = originalEntity
    }
    
    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, watchOS 6.2, *)
    init(
        productType: ProductType,
        productIdentifier: String,
        localizedDescription: String,
        localizedTitle: String,
        currencyCode: String?,
        price: Decimal,
        subscriptionPeriod: SubscriptionPeriod?,
        introductoryDiscount: ProductDiscount?,
        discounts: [ProductDiscount],
        originalEntity: Any
    ) {
        self.productType = productType
        self.productIdentifier = productIdentifier
        self.localizedDescription = localizedDescription
        self.localizedTitle = localizedTitle
        self.currencyCode = currencyCode
        self.price = price
        self._subscriptionPeriod = subscriptionPeriod
        self._introductoryDiscount = introductoryDiscount
        self._discounts = discounts
        self.originalEntity = originalEntity
    }
}

extension Product: Hashable {
    public static func == (lhs: Product, rhs: Product) -> Bool {
        let partiallyEqual = lhs.productType == rhs.productType
        && lhs.productIdentifier == rhs.productIdentifier
        && lhs.localizedDescription == rhs.localizedDescription
        && lhs.localizedTitle == rhs.localizedTitle
        && lhs.currencyCode == rhs.currencyCode
        && lhs.price == rhs.price
        
        guard partiallyEqual else {
            return false
        }
        
        if #available(iOS 11.2, *) {
            guard lhs.subscriptionPeriod == rhs.subscriptionPeriod,
                  lhs.introductoryDiscount.isEqual(to: rhs.introductoryDiscount) else {
                return false
            }
        }
        
        if #available(iOS 12.2, *) {
            guard lhs.discounts.count == rhs.discounts.count else {
                return false
            }
            
            for i in lhs.discounts.indices {
                guard (lhs.discounts[i] as ProductDiscount?).isEqual(to: rhs.discounts[i]) else {
                    return false
                }
            }
        }
        
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        productType.hash(into: &hasher)
        productIdentifier.hash(into: &hasher)
        localizedDescription.hash(into: &hasher)
        localizedTitle.hash(into: &hasher)
        currencyCode.hash(into: &hasher)
        price.hash(into: &hasher)
        
        if #available(iOS 11.2, *) {
            subscriptionPeriod.hash(into: &hasher)
            introductoryDiscount?.hashValue.hash(into: &hasher)
        }
        
        if #available(iOS 12.2, *) {
            discounts.forEach {
                $0.hashValue.hash(into: &hasher)
            }
        }
    }
}
