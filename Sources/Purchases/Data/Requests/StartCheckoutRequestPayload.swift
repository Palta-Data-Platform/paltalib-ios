//
//  StartCheckoutRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 26/08/2022.
//

import Foundation

struct StartCheckoutRequestPayload: Encodable, Equatable {
    let customerId: UserId
}
