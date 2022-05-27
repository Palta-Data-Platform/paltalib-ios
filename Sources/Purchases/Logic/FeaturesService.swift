//
//  FeaturesService.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import PaltaLibCore

protocol FeaturesService {
    func getFeatures(for userId: UserId, completion: @escaping (Result<[Feature], PaymentsError>) -> Void)
}

final class FeaturesServiceImpl: FeaturesService {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func getFeatures(for userId: UserId, completion: @escaping (Result<[Feature], PaymentsError>) -> Void) {
        let request = PaymentsHTTPRequest.getFeatures(userId)
        
        httpClient.perform(request) { (result: Result<FeaturesResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.features))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
}
