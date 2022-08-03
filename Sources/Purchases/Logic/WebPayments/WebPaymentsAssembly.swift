//
//  WebPaymentsAssembly.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import PaltaLibCore

final class WebPaymentsAssembly {
    let paidFeaturesService: PaidFeaturesService
    
    private init(paidFeaturesService: PaidFeaturesService) {
        self.paidFeaturesService = paidFeaturesService
    }
}

extension WebPaymentsAssembly {
    convenience init(apiKey: String, environment: Environment, coreAssembly: CoreAssembly) {
        coreAssembly.httpClient.mandatoryHeaders = ["x-api-key": apiKey]

        let featureMapper = FeatureMapperImpl()
        let featuresService = FeaturesServiceImpl(environment: environment, httpClient: coreAssembly.httpClient)
        let subscriptionsService = SubscriptionsServiceImpl(environment: environment, httpClient: coreAssembly.httpClient)
        
        let paidFeaturesService: PaidFeaturesService = PaidFeaturesServiceImpl(
            subscriptionsService: subscriptionsService,
            featuresService: featuresService,
            featureMapper: featureMapper
        )
        
        self.init(paidFeaturesService: paidFeaturesService)
    }
}
