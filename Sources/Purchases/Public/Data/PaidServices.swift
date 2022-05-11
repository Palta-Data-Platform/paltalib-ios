//
//  PaidServices.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

public struct PaidServices: Equatable {
    private var servicesByName: [String: [PaidService]]
    
    init(services: [PaidService] = []) {
        servicesByName = Dictionary(grouping: services, by: { $0.name })
    }
    
    mutating func merge(with paidServices: PaidServices) {
        paidServices.servicesByName.forEach {
            servicesByName[$0.key] = (servicesByName[$0.key] ?? []) + $0.value
        }
    }
    
    func merged(with paidServices: PaidServices) -> PaidServices {
        var copy = self
        copy.merge(with: paidServices)
        return copy
    }
}

extension PaidServices {
    public func hasActiveService(with name: String) -> Bool {
        servicesByName[name]?.contains(where: { $0.isActive }) ?? false
    }
}

extension PaidServices {
    public var services: [PaidService] {
        servicesByName.values.flatMap { $0 }
    }
    
    public subscript(_ name: String) -> [PaidService] {
        servicesByName[name] ?? []
    }
}
