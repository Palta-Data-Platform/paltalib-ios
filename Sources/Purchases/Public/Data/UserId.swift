//
//  UserId.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 17/05/2022.
//

import Foundation

public enum UserId: Equatable {
    case uuid(UUID)
}

extension UserId {
    var stringValue: String {
        switch self {
        case .uuid(let uuid):
            return uuid.uuidString
        }
    }
}

extension UserId: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .uuid(let uuid):
            try container.encode(uuid, forKey: .value)
            try container.encode("merchant-uuid", forKey: .type)
        }
    }
}
