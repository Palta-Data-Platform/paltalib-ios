//
//  FeatureMapperMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaLibPayments

final class FeatureMapperMock: FeatureMapper {
    var features: [Feature]?
    var subscriptions: [Subscription]?
    
    var result = [PaidFeature(name: "feature", startDate: Date(timeIntervalSince1970: 0))]
    
    func map(_ features: [Feature], and subscriptions: [Subscription]) -> [PaidFeature] {
        self.features = features
        self.subscriptions = subscriptions
        
        return result
    }
}
