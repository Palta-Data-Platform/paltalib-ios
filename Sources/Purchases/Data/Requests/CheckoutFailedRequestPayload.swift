//
//  CheckoutFailedRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 29/08/2022.
//

import Foundation

struct CheckoutFailedRequestPayload: Equatable, Encodable {
    let orderId: UUID
}