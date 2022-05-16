//
//  CustomerInfo+PaidServices.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 13/05/2022.
//

import Foundation
import RevenueCat

extension CustomerInfo {
    var paidServices: PaidServices {
        PaidServices(
            services: entitlements.all.values.map {
                PaidService(
                    name: $0.identifier,
                    startDate: $0.latestPurchaseDate ?? Date(timeIntervalSince1970: 0),
                    endDate: $0.expirationDate
                )
            }
        )
    }
}
