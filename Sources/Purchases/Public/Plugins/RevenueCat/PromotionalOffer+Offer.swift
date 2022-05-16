//
//  PromotionalOffer+Offer.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import RevenueCat

extension PromotionalOffer: PromoOffer {
    public var productDiscount: ProductDiscount {
        discount
    }
}
