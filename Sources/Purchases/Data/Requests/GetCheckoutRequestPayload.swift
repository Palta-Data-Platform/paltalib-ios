//
//  GetCheckoutRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 30/08/2022.
//

import Foundation

struct GetCheckoutRequestPayload: Equatable, Encodable {
    let orderId: UUID
}
