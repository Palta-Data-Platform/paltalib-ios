//
//  CheckoutCompletedRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 29/08/2022.
//

import Foundation

struct CheckoutCompletedRequestPayload: Encodable, Equatable {
    struct Purchase: Encodable, Equatable {
        let receiptData: String
        let transactionId: String
        let originalTransactionId: String
    }
    
    let orderId: UUID
    let purchase: Purchase
}
