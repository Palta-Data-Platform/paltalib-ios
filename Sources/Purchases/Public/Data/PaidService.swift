//
//  PaidService.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

public struct PaidService: Hashable {
    public enum PaymentType {
        case subscription
        case oneOff
        case consumable
    }
    
    public enum TransactionType {
        case web
        case appStore
        case googlePlay
    }
    
    public let name: String
    public let productIdentifier: String?
    public let paymentType: PaymentType
    public let transactionType: TransactionType
    public let isTrial: Bool
    
    public let startDate: Date
    public let endDate: Date?
    public let cancellationDate: Date?
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
