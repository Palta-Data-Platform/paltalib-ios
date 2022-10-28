//
//  CheckoutFailedRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 29/08/2022.
//

import Foundation
import PaltaLibCore

struct CheckoutFailedRequestPayload: Equatable, Encodable {
    struct Purchase: Equatable, Encodable {
        let errorCode: String
        let errorMessage: String
    }
    
    let orderId: UUID
    let purchase: Purchase
}
