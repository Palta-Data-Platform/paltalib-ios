//
//  GetFeaturesRequestPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

struct GetFeaturesRequestPayload: Encodable {
    let customerId: UserId
}
