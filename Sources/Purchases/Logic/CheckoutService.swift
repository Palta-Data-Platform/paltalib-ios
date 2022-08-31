//
//  CheckoutService.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 26/08/2022.
//

import Foundation
import PaltaLibCore

protocol CheckoutService {
    func startCheckout(
        userId: UserId,
        traceId: UUID,
        completion: @escaping (Result<UUID, PaymentsError>) -> Void
    )
    
    func completeCheckout(
        orderId: UUID,
        receiptData: Data,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    )
    
    func failCheckout(
        orderId: UUID,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    )
    
    func getCheckout(
        orderId: UUID,
        traceId: UUID,
        completion: @escaping (Result<CheckoutState, PaymentsError>) -> Void
    )
}

final class CheckoutServiceImpl: CheckoutService {
    private let environment: Environment
    private let httpClient: HTTPClient
    
    init(environment: Environment, httpClient: HTTPClient) {
        self.environment = environment
        self.httpClient = httpClient
    }

    func startCheckout(
        userId: UserId,
        traceId: UUID,
        completion: @escaping (Result<UUID, PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .startCheckout(userId)
        )
        
        httpClient.perform(request) { (result: Result<StartCheckoutResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.orderId))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
    
    func completeCheckout(
        orderId: UUID,
        receiptData: Data,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .checkoutCompleted(orderId, receiptData.base64EncodedString())
        )
        
        httpClient.perform(request) { (result: Result<StatusReponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
    
    func failCheckout(
        orderId: UUID,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .checkoutFailed(orderId)
        )
        
        httpClient.perform(request) { (result: Result<StatusReponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
    
    func getCheckout(
        orderId: UUID,
        traceId: UUID,
        completion: @escaping (Result<CheckoutState, PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .getCheckout(orderId)
        )
        
        httpClient.perform(request) { (result: Result<GetCheckoutReponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.state))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
}
