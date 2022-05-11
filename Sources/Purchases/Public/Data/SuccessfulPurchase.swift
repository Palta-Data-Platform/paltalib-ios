//
//  SuccessfulPurchase.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

public struct SuccessfulPurchase {
    public let transaction: Transaction
    public let paidServices: PaidServices
    
    public init(transaction: Transaction, paidServices: PaidServices) {
        self.transaction = transaction
        self.paidServices = paidServices
    }
}
