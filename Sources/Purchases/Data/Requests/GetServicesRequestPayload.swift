//
//  GetServicesRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

struct GetServicesRequestPayload: Encodable {
    let customerId: UserId
}
