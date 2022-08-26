//
//  ShowcaseService.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 18/08/2022.
//

import PaltaLibCore
import Foundation

protocol ShowcaseService {
    func getProductIds(for userId: UserId, traceId: UUID, _ completion: @escaping (Result<[PricePoint], PaymentsError>) -> Void)
}

final class ShowcaseServiceImpl: ShowcaseService {
    private let environment: Environment
    private let httpClient: HTTPClient
    
    init(environment: Environment, httpClient: HTTPClient) {
        self.environment = environment
        self.httpClient = httpClient
    }
    
    func getProductIds(for userId: UserId, traceId: UUID, _ completion: @escaping (Result<[PricePoint], PaymentsError>) -> Void) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .getShowcase(userId, nil)
        )
        
        httpClient
            .perform(request) { (result: Result<ShowcaseResponse, NetworkErrorWithoutResponse>) in
            completion(
                result
                    .map { $0.pricePoints }
                    .mapError { PaymentsError(networkError: $0) }
            )
        }
    }
}
