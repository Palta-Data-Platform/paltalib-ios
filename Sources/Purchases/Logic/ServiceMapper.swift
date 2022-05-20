//
//  ServiceMapper.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

protocol ServiceMapper {
    func map(_ services: [Service], and subscriptions: [Subscription]) -> [PaidService]
}

final class ServiceMapperImpl: ServiceMapper {
    func map(_ services: [Service], and subscriptions: [Subscription]) -> [PaidService] {
        let subscriptionById = Dictionary
            .init(grouping: subscriptions, by: { $0.id })
            .compactMapValues { $0.first }
        
        return services.map {
            PaidService(
                name: $0.sku,
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

private extension Service {
    func paymentType(subscriptions: [UUID: Subscription]) -> PaidService.PaymentType {
        return .oneOff
    }
    
    func isTrial(subscriptions: [UUID: Subscription]) -> Bool {
        false
    }
    
    func cancellationDate(subscriptions: [UUID: Subscription]) -> Date? {
        nil
    }
}
