//
//  StartCheckoutResponse.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 31/08/2022.
//

import Foundation

struct StartCheckoutResponse: Decodable {
    let status: String
    let orderId: UUID
}
