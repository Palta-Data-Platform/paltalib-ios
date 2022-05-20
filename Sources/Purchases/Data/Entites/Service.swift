//
//  Service.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

struct Service: Decodable {
    let quantity: Int
    let actualFrom: Date
    let actualTill: Date
    let sku: String
}
