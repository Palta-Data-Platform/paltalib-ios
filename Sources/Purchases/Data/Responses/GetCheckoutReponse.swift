//
//  GetCheckoutReponse.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 31/08/2022.
//

import Foundation

struct GetCheckoutReponse: Decodable {
    let status: String
    let state: CheckoutState
}
