//
//  ProductDiscountMock.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import Foundation
import PaltaLibPayments

struct ProductDiscountMock: ProductDiscount {
    var offerIdentifier: String?
    var currencyCode: String?
    var price: Decimal = 0
    var numberOfPeriods: Int = 0
}
