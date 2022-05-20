//
//  GetSubscriptionsRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

struct GetSubscriptionsRequestPayload: Encodable {
    let customerId: UserId
    let onlyIds: Set<UUID>?
}
