//
//  PromoOfferMock.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import Foundation
import PaltaLibPayments

struct PromoOfferMock: PromoOffer {
    var productDiscount: ProductDiscount = ProductDiscountMock()
}
