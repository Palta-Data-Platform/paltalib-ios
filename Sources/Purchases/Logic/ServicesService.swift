//
//  ServicesService.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import PaltaLibCore

protocol ServicesService {
    func getServices(for userId: UserId, completion: @escaping (Result<[Service], Error>) -> Void)
}

final class ServicesServiceImpl: ServicesService {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func getServices(for userId: UserId, completion: @escaping (Result<[Service], PaymentsError>) -> Void) {
        let request = PaymentsHTTPRequest.getServices(userId)
        
        httpClient.perform(request) { (result: Result<ServiceResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.services))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
}
