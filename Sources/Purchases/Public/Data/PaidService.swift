//
//  PaidService.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

public struct PaidService: Equatable {
    public let name: String
    public let startDate: Date
    public let endDate: Date?
}

extension PaidService {
    public var isLifetime: Bool {
        endDate == nil
    }
    
    public var isActive: Bool {
        let now = Date()
        
        return now > startDate && endDate.map { $0 > now } ?? true
    }
}
