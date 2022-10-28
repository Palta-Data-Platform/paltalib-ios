//
//  ShowcaseResponse.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import Foundation

struct ShowcaseResponse {
    let status: String
    let pricePoints: [PricePoint]
}

extension ShowcaseResponse: Decodable {
    enum CodingKeys: CodingKey {
        case status
        case pricePoints
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        var ppContainer = try container.nestedUnkeyedContainer(forKey: .pricePoints)
        
        var pricePoints: [PricePoint] = []
        
        while !ppContainer.isAtEnd {
            guard let element = try? ppContainer.decode(PricePoint.self) else {
                ppContainer.skip()
                continue
            }
            
            pricePoints.append(element)
        }
        
        self.status = try container.decode(String.self, forKey: .status)
        self.pricePoints = pricePoints
    }
}

private extension UnkeyedDecodingContainer {
    mutating func skip() {
        _ = try? decode(DummyValue.self)
    }
}

private struct DummyValue: Decodable {
    init(from decoder: Decoder) throws {
    }
}
