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
        completion: @escaping (Result<[Subscription], PaymentsError>) -> Void
    )
}

final class SubscriptionsServiceImpl: SubscriptionsService {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func getSubscriptions(
        with ids: Set<UUID>,
        for userId: UserId,
        completion: @escaping (Result<[Subscription], PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest.getSubcriptions(userId, ids)
        
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
