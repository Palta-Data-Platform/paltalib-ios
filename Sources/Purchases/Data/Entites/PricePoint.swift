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
    let priority: Int?
}

extension PricePoint: Decodable {
    private enum TopCodingKeys: CodingKey {
        case ident
        case priority
        case appleStore
    }
    
    private enum AppleStoreCodingKeys: CodingKey {
        case productId
    }
    
    init(from decoder: Decoder) throws {
        let topContainer = try decoder.container(keyedBy: TopCodingKeys.self)
        let appleStoreContainer = try topContainer.nestedContainer(keyedBy: AppleStoreCodingKeys.self, forKey: .appleStore)
        
        self.ident = try topContainer.decode(String.self, forKey: .ident)
        self.productId = try appleStoreContainer.decode(String.self, forKey: .productId)
        self.priority = try topContainer.decodeIfPresent(Int.self, forKey: .priority)
    }
}
