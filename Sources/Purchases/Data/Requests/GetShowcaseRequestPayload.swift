//
//  GetShowcaseRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import Foundation
import PaltaLibCore

struct GetShowcaseRequestPayload: Encodable {
    let customerId: UserId
    let countryCode: String?
    let storeType: Int = 2
    let requestContext: CodableDictionary = [:]
}
