//
//  CustomerInfo+PaidFeatures.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 13/05/2022.
//

import Foundation
import RevenueCat

extension CustomerInfo {
    var paidFeatures: PaidFeatures {
        PaidFeatures(
            features: subscriptionFeatures + nonSubscriptionFeatures
        )
    }
    
    private var subscriptionFeatures: [PaidFeature] {
        entitlements.all.values.map {
            PaidFeature(
                name: $0.identifier,
                productIdentifier: $0.productIdentifier,
                paymentType: .subscription,
                transactionType: $0.store.transactionType,
                isTrial: $0.periodType == .trial,
                willRenew: $0.willRenew,
                startDate: $0.latestPurchaseDate ?? Date(timeIntervalSince1970: 0),
                endDate: $0.expirationDate,
                cancellationDate: $0.unsubscribeDetectedAt
            )
        }
    }
    
    private var nonSubscriptionFeatures: [PaidFeature] {
        nonSubscriptionTransactions.map {
            PaidFeature(
                name: $0.productIdentifier,
                productIdentifier: $0.productIdentifier,
                paymentType: .oneOff,
                transactionType: .appStore,
                isTrial: false,
                willRenew: false,
                startDate: $0.purchaseDate,
                endDate: nil,
                cancellationDate: nil
            )
        }
    }
}

private extension Store {
    var transactionType: PaidFeature.TransactionType {
        switch self {
        case .appStore, .macAppStore:
            return .appStore
        case .playStore, .amazon:
            return .googlePlay
        case .stripe, .promotional, .unknownStore:
            return .web
        }
    }
}
