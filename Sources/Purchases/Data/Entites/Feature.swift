//
//  Feature.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

struct Feature: Decodable, Equatable {
    let quantity: Int
    let actualFrom: Date
    let actualTill: Date
    let feature: String
    let lastSubscriptionId: UUID?
}
