//
//  AppstoreProductMapper.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 19/08/2022.
//

import Foundation
import StoreKit

protocol AppstoreProductMapper {
    func map(_ appStoreProduct: SKProduct) -> Product
}

final class AppstoreProductMapperImpl: AppstoreProductMapper {
    private var priceFormatters: [Locale: NumberFormatter] = [:]
    
    func map(_ appStoreProduct: SKProduct) -> Product {
        if #available(iOS 12.2, *) {
            return Product(
                productType: .nonConsumable,
                productIdentifier: appStoreProduct.productIdentifier,
                localizedDescription: appStoreProduct.localizedDescription,
                localizedTitle: appStoreProduct.localizedTitle,
                currencyCode: appStoreProduct.priceLocale.currencyCode,
                price: appStoreProduct.price.decimalValue,
                localizedPriceString: priceString(locale: appStoreProduct.priceLocale, price: appStoreProduct.price),
                subscriptionPeriod: appStoreProduct.subscriptionPeriod.map(SubscriptionPeriod.init),
                introductoryDiscount: appStoreProduct.introductoryPrice.map {
                    ProductDiscount(sk: $0, priceFormatter: priceString(locale:price:))
                },
                discounts: appStoreProduct.discounts.map {
                    ProductDiscount(sk: $0, priceFormatter: priceString(locale:price:))
                },
                originalEntity: appStoreProduct
            )
        } else {
            fatalError()
        }
    }
    
    private func priceString(locale: Locale, price: NSDecimalNumber) -> String {
        priceFormatter(for: locale).string(from: price) ?? ""
    }
    
    private func priceFormatter(for locale: Locale) -> NumberFormatter {
        if let priceFormatter = priceFormatters[locale] {
            return priceFormatter
        }
        
        let priceFormatter = NumberFormatter()
        priceFormatter.locale = locale
        priceFormatter.numberStyle = .currency
        priceFormatters[locale] = priceFormatter
        return priceFormatter
    }
}

private extension SubscriptionPeriod {
    init(sk: SKProductSubscriptionPeriod) {
        self.init(
            value: sk.numberOfUnits,
            unit: Unit(sk: sk.unit)
        )
    }
}

private extension SubscriptionPeriod.Unit {
    init(sk: SKProduct.PeriodUnit) {
        switch sk {
        case .year:
            self = .year
        case .month:
            self = .month
        case .week:
            self = .week
        case .day:
            self = .day
        @unknown default:
            fatalError()
        }
    }
}

private extension ProductDiscount {
    init(sk: SKProductDiscount, priceFormatter: (Locale, NSDecimalNumber) -> String) {
        self.init(
            offerIdentifier: sk.identifier,
            currencyCode: sk.priceLocale.currencyCode,
            price: sk.price.decimalValue,
            numberOfPeriods: sk.numberOfPeriods,
            subscriptionPeriod: SubscriptionPeriod(sk: sk.subscriptionPeriod),
            localizedPriceString: priceFormatter(sk.priceLocale, sk.price),
            originalEntity: sk
        )
    }
}
