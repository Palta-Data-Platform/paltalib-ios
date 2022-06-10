//
//  PaidFeatures.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

public struct PaidFeatures: Equatable {
    private var featuresByName: [String: Set<PaidFeature>]
    
    init(features: [PaidFeature] = []) {
        featuresByName = Dictionary(grouping: features, by: { $0.name }).mapValues { Set($0) }
    }
    
    mutating func merge(with paidFeatures: PaidFeatures) {
        paidFeatures.featuresByName.forEach {
            featuresByName[$0.key] = (featuresByName[$0.key] ?? []).union($0.value)
        }
    }
    
    func merged(with paidFeatures: PaidFeatures) -> PaidFeatures {
        var copy = self
        copy.merge(with: paidFeatures)
        return copy
    }
}

extension PaidFeatures {
    public func hasActiveFeature(with name: String) -> Bool {
        featuresByName[name]?.contains(where: { $0.isActive }) ?? false
    }
}

extension PaidFeatures {
    public var features: [PaidFeature] {
        featuresByName.values.flatMap { $0 }
    }
    
    public var activeFeatures: [PaidFeature] {
        features.filter { $0.isActive }
    }
    
    public subscript(_ name: String) -> [PaidFeature] {
        featuresByName[name].map(Array.init) ?? []
    }
}
