//
//  RestorePurchasesPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 29/11/2022.
//

import Foundation

struct RestorePurchasesPayload: Encodable, Equatable {
    let customerId: UserId
    let receiptData: String
}
