//
//  ProductMock.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import Foundation
@testable import PaltaLibPayments

extension Product {
    static func mock() -> Product {
        .init(
            productType: .nonRenewableSubscription,
            productIdentifier: "",
            localizedDescription: "",
            localizedTitle: "",
            currencyCode: nil,
            price: 0,
            originalEntity: 0
        )
    }
}
