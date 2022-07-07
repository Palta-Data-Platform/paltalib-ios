//
//  ProductDiscountMock.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import Foundation
@testable import PaltaLibPayments

extension ProductDiscount {
    static func mock() -> ProductDiscount {
        .init(
            offerIdentifier: nil,
            currencyCode: nil,
            price: 0,
            numberOfPeriods: 0,
            subscriptionPeriod: .init(value: 0, unit: .month),
            localizedPriceString: "",
            originalEntity: 0
        )
    }
}
