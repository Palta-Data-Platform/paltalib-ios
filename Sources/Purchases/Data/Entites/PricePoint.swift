//
//  PricePoint.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import Foundation

struct PricePoint: Decodable, Equatable {
    struct Parameters: Decodable, Equatable {
        let productId: String
    }
    
    let ident: String
    let parameters: Parameters
    let priority: Int?
}
