//
//  FeatureMapper.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

protocol FeatureMapper {
    func map(_ features: [Feature], and subscriptions: [Subscription]) -> [PaidFeature]
}

final class FeatureMapperImpl: FeatureMapper {
    func map(_ features: [Feature], and subscriptions: [Subscription]) -> [PaidFeature] {
        let subscriptionById = Dictionary
            .init(grouping: subscriptions, by: { $0.id })
            .compactMapValues { $0.first }
        
        return features.map {
            PaidFeature(
                name: $0.feature,
                productIdentifier: nil,
                paymentType: $0.paymentType(subscriptions: subscriptionById),
                transactionType: .web,
                isTrial: $0.isTrial(subscriptions: subscriptionById),
                startDate: $0.actualFrom,
                endDate: $0.actualTill,
                cancellationDate: $0.cancellationDate(subscriptions: subscriptionById)
            )
        }
    }
}

private extension Feature {
    func paymentType(subscriptions: [UUID: Subscription]) -> PaidFeature.PaymentType {
        lastSubscriptionId.flatMap { subscriptions[$0] } != nil ? .subscription : .oneOff
    }
    
    func isTrial(subscriptions: [UUID: Subscription]) -> Bool {
        lastSubscriptionId.flatMap { subscriptions[$0]?.tags.contains(.trial) } ?? false
    }
    
    func cancellationDate(subscriptions: [UUID: Subscription]) -> Date? {
        lastSubscriptionId.flatMap { subscriptions[$0]?.canceledAt }
    }
}
