//
//  Product.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 08.05.2022.
//

import Foundation

public enum ProductType {
    /// A consumable in-app purchase.
    case consumable

    /// A non-consumable in-app purchase.
    case nonConsumable

    /// A non-renewing subscription.
    case nonRenewableSubscription

    /// An auto-renewable subscription.
    case autoRenewableSubscription

}

public struct SubscriptionPeriod {
    public enum Unit: Int {
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

public protocol Product {
    var productType: ProductType { get }
    var productIdentifier: String { get }
    var localizedDescription: String { get }
    var localizedTitle: String { get }
    var currencyCode: String? { get }
    var price: Decimal { get }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    var subscriptionPeriod: SubscriptionPeriod? { get }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    var introductoryDiscount: ProductDiscount? { get }

    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, watchOS 6.2, *)
    var discounts: [ProductDiscount] { get }
}
