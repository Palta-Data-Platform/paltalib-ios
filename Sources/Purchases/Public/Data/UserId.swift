//
//  UserId.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 17/05/2022.
//

import Foundation

public enum UserId: Equatable {
    case uuid(UUID)
    case string(String)
}

extension UserId {
    var stringValue: String {
        switch self {
        case .uuid(let uuid):
            return uuid.uuidString
        case .string(let string):
            return string
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
        case .string(let string):
            try container.encode(string, forKey: .value)
            try container.encode("merchant-str", forKey: .type)
        }
    }
}
