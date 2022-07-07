//
//  PaidFeatureMock.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 17/05/2022.
//

@testable import PaltaLibPayments
import Foundation

extension PaidFeature {
    init(name: String, startDate: Date, endDate: Date? = nil) {
        self.init(
            name: name,
            productIdentifier: nil,
            paymentType: .subscription,
            transactionType: .appStore,
            isTrial: false,
            willRenew: false,
            startDate: startDate,
            endDate: endDate,
            cancellationDate: nil
        )
    }
}
