//
//  WebPaymentsAssembly.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import PaltaLibCore

final class WebPaymentsAssembly {
    private(set) lazy var paidFeaturesService: PaidFeaturesService = PaidFeaturesServiceImpl(
        subscriptionsService: subscriptionsService,
        featuresService: featuresService,
        featureMapper: featureMapper
    )
    
    private lazy var featureMapper = FeatureMapperImpl()
    private lazy var featuresService = FeaturesServiceImpl(httpClient: coreAssembly.httpClient)
    private lazy var subscriptionsService = SubscriptionsServiceImpl(httpClient: coreAssembly.httpClient)
    
    private let coreAssembly: CoreAssembly
    
    init(coreAssembly: CoreAssembly) {
        self.coreAssembly = coreAssembly
    }
}
