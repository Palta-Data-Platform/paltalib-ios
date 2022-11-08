//
//  AppstoreProductMapper.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 19/08/2022.
//

import Foundation
import StoreKit

protocol AppstoreProductMapper: AnyObject {
    func map(_ appStoreProduct: SKProduct, pricePoints: [String: [PricePoint]]) -> [Product]
}

final class AppstoreProductMapperImpl: AppstoreProductMapper {
    private var priceFormatters: [Locale: NumberFormatter] = [:]
    
    func map(_ appStoreProduct: SKProduct, pricePoints: [String: [PricePoint]]) -> [Product] {
        guard let pricePoints = pricePoints[appStoreProduct.productIdentifier] else {
            fatalError()
        }
        
        return pricePoints.compactMap { (pricePoint) -> Product? in
            let appliedDiscount: SKProductDiscount?
            
            if pricePoint.useIntroOffer, let introOffer = appStoreProduct.introductoryPrice {
                appliedDiscount = introOffer
            } else if !pricePoint.useIntroOffer {
                appliedDiscount = nil
            } else {
                return nil
            }
            
            return Product(
                productType: appStoreProduct.subscriptionPeriod != nil ? .autoRenewableSubscription : .nonConsumable,
                productIdentifier: appStoreProduct.productIdentifier,
                localizedDescription: appStoreProduct.localizedDescription,
                localizedTitle: appStoreProduct.localizedTitle,
                currencyCode: appStoreProduct.priceLocale.currencyCode,
                price: appStoreProduct.price.decimalValue,
                localizedPriceString: priceString(locale: appStoreProduct.priceLocale, price: appStoreProduct.price),
                subscriptionPeriod: appStoreProduct.subscriptionPeriod.map(SubscriptionPeriod.init),
                appliedDiscount: appliedDiscount.map { ProductDiscount(sk: $0, priceFormatter: priceString(locale:price:)) },
                introductoryDiscount: nil,
                discounts: [],
                originalEntity: ShowcaseProduct(
                    ident: pricePoint.ident,
                    skProduct: appStoreProduct,
                    discount: appliedDiscount,
                    priority: pricePoint.priority
                )
            )
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
