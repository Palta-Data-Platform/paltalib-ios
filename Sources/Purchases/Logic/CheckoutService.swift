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
        ident: String,
        traceId: UUID,
        completion: @escaping (Result<UUID, PaymentsError>) -> Void
    )
    
    func completeCheckout(
        orderId: UUID,
        receiptData: Data,
        transactionId: String,
        originalTransactionId: String,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    )
    
    func failCheckout(
        orderId: UUID,
        error: PaymentsError,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    )
    
    func getCheckout(
        orderId: UUID,
        traceId: UUID,
        completion: @escaping (Result<CheckoutState, PaymentsError>) -> Void
    )
    
    func restorePurchases(
        customerId: UserId,
        receiptData: Data,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    )
    
    func log(
        level: LogPayload.Level,
        event: String,
        data: [String: Any]?,
        traceId: UUID
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
        ident: String,
        traceId: UUID,
        completion: @escaping (Result<UUID, PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .startCheckout(userId, ident)
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
        transactionId: String,
        originalTransactionId: String,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .checkoutCompleted(orderId, receiptData.base64EncodedString(), transactionId, originalTransactionId)
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
        error: PaymentsError,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .checkoutFailed(orderId, error.code, error.localizedDescription)
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
    
    func restorePurchases(
        customerId: UserId,
        receiptData: Data,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .restorePurchase(customerId, receiptData.base64EncodedString())
        )
        
        httpClient.perform(request) { (result: Result<EmptyResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
    
    func log(level: LogPayload.Level, event: String, data: [String : Any]?, traceId: UUID) {
        let request = PaymentsHTTPRequest(
            environment: environment,
            traceId: traceId,
            endpoint: .log(level, event, data.map(CodableDictionary.init))
        )
        
        httpClient.perform(request) { (_: Result<StatusReponse, NetworkErrorWithoutResponse>) in
        }
    }
}
