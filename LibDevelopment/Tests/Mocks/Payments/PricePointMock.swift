//
//  PricePointMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 22/08/2022.
//

import Foundation
@testable import PaltaLibPayments

extension PricePoint {
    static func mock(priority: Int? = nil, appStoreId: String = UUID().uuidString, ident: String = UUID().uuidString) -> PricePoint {
        PricePoint(ident: ident, productId: appStoreId, priority: priority)
    }
}
