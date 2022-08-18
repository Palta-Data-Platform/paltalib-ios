//
//  ShowcaseResponse.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import Foundation

struct ShowcaseResponse: Decodable {
    let status: String
    let pricePoints: [PricePoint]
}
