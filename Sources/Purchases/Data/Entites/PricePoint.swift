//
//  PricePoint.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import Foundation

struct PricePoint: Decodable, Equatable {
    let ident: String
    let appStoreId: String
    let priority: Int?
}
