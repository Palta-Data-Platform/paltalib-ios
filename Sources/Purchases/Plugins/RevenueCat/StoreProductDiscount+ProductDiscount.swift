//
//  StoreProductDiscount+ProductDiscount.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import RevenueCat

extension ProductDiscount {
    init(rc: StoreProductDiscount) {
        self.init(
            offerIdentifier: rc.offerIdentifier,
            currencyCode: rc.currencyCode,
            price: rc.price,
            numberOfPeriods: rc.numberOfPeriods,
            subscriptionPeriod: SubscriptionPeriod(rc: rc.subscriptionPeriod),
            originalEntity: rc
        )
    }
}
