//
//  PricePoint.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import Foundation

struct PricePoint: Equatable {
    let ident: String
    let productId: String
    let useIntroOffer: Bool
    let priority: Int?
}

extension PricePoint: Decodable {
    enum CodingKeys: CodingKey {
        case ident
        case productId
        case useIntroOffer
        case priority
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.ident = try container.decode(String.self, forKey: .ident)
        self.productId = try container.decode(String.self, forKey: .productId)
        self.useIntroOffer = try container.decodeIfPresent(Bool.self, forKey: .useIntroOffer) ?? false
        self.priority = try container.decodeIfPresent(Int.self, forKey: .priority)
    }
}
