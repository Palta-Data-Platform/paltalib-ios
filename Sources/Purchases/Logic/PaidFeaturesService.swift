//
//  PaidFeaturesService.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation

protocol PaidFeaturesService {
    func getPaidFeatures(
        for userId: UserId,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    )
}

final class PaidFeaturesServiceImpl: PaidFeaturesService {
    private let subscriptionsService: SubscriptionsService
    private let featuresService: FeaturesService
    private let featureMapper: FeatureMapper
    
    init(
        subscriptionsService: SubscriptionsService,
        featuresService: FeaturesService,
        featureMapper: FeatureMapper
    ) {
        self.subscriptionsService = subscriptionsService
        self.featuresService = featuresService
        self.featureMapper = featureMapper
    }
    
    func getPaidFeatures(
        for userId: UserId,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        featuresService.getFeatures(for: userId) { [weak self] result in
            switch result {
            case .success(let features):
                self?.getSubscriptions(userId: userId, features: features, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getSubscriptions(
        userId: UserId,
        features: [Feature],
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        let subscriptionIds = Set(features.compactMap { $0.lastSubscriptionId })
        
        guard !subscriptionIds.isEmpty else {
            prepareData(features: features, subscriptions: [], completion: completion)
            return
        }
        
        subscriptionsService.getSubscriptions(with: subscriptionIds, for: userId) { [weak self] result in
            switch result {
            case .success(let subscriptions):
                self?.prepareData(
                    features: features,
                    subscriptions: subscriptions,
                    completion: completion
                )
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func prepareData(
        features: [Feature],
        subscriptions: [Subscription],
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        let paidFeatures = featureMapper.map(features, and: subscriptions)
        completion(.success(PaidFeatures(features: paidFeatures)))
    }
}
