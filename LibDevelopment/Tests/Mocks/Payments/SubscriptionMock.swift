//
//  SubscriptionMock.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaLibPayments

extension Subscription {
    static func mock() -> Subscription {
        Subscription(
            id: .init(),
            state: .active,
            createdAt: Date(timeIntervalSince1970: 0),
            canceledAt: Date(timeIntervalSince1970: 12),
            currentPeriodStartAt: Date(timeIntervalSince1970: 6),
            currentPeriodEndAt: Date(timeIntervalSince1970: 18),
            tags: [.trial]
        )
    }
}
