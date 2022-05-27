//
//  SuccessfulPurchase.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

public struct SuccessfulPurchase {
    public let transaction: Transaction
    public let paidFeatures: PaidFeatures
    
    public init(transaction: Transaction, paidFeatures: PaidFeatures) {
        self.transaction = transaction
        self.paidFeatures = paidFeatures
    }
}
