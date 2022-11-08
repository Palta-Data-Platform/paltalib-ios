//
//  PricePointMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 22/08/2022.
//

import Foundation
@testable import PaltaLibPayments

extension PricePoint {
    static func mock(priority: Int? = nil, appStoreId: String = UUID().uuidString, ident: String = UUID().uuidString, useIntroOffer: Bool = true) -> PricePoint {
        PricePoint(ident: ident, productId: appStoreId, useIntroOffer: useIntroOffer, priority: priority)
    }
}
