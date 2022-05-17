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
