//
//  GetShowcaseRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import Foundation

struct GetShowcaseRequestPayload: Encodable {
    let customerId: UserId
    let countryCode: String?
    let platformCode: String = "ios"
}
