//
//  SubscriptionsService.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import PaltaLibCore

protocol SubscriptionsService {
    func getSubscriptions(
        with ids: Set<UUID>,
        for userId: UserId,
        traceId: UUID,
        completion: @escaping (Result<[Subscription], PaymentsError>) -> Void
    )
}

final class SubscriptionsServiceImpl: SubscriptionsService {
    private let environment: Environment
    private let httpClient: HTTPClient
    
    init(environment: Environment, httpClient: HTTPClient) {
        self.environment = environment
        self.httpClient = httpClient
    }
    
    func getSubscriptions(
        with ids: Set<UUID>,
        for userId: UserId,
        traceId: UUID,
        completion: @escaping (Result<[Subscription], PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .getSubcriptions(userId, ids)
        )
        
        httpClient.perform(request) { (result: Result<SubscriptionResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.subscriptions))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
}
