//
//  BatchSender.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 02/06/2022.
//

import Foundation
import CoreData
import PaltaLibCore
import PaltaLibAnalyticsModel

enum BatchSendError: Error {
    case serializationError(Error)
    case networkError(URLError)
    case notConfigured
    case serverError
    case noInternet
    case timeout
    case unknown
}

protocol BatchSender {
    func sendBatch(_ batch: Batch, completion: @escaping (Result<(), BatchSendError>) -> Void)
}

final class BatchSenderImpl: BatchSender {
    var apiToken: String? {
        didSet {
            httpClient.mandatoryHeaders["X-API-Key"] = apiToken ?? ""
        }
    }
    
    var url: URL?
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func sendBatch(_ batch: Batch, completion: @escaping (Result<(), BatchSendError>) -> Void) {
        guard let url = url else {
            completion(.failure(.notConfigured))
            return
        }

        let data: Data
        
        do {
            data = try batch.serialize()
        } catch {
            completion(.failure(.serializationError(error)))
            return
        }
        
        let request = BatchSendRequest(
            url: url,
            time: currentTimestamp(),
            data: data
        )
        
        let errorHandler = ErrorHandler(completion: completion)
        
        httpClient.perform(request) { (result: Result<EmptyResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                errorHandler.handle(error)
            }
        }
    }
}

private struct ErrorHandler {
    let completion: (Result<Void, BatchSendError>) -> Void
    
    func handle(_ error: NetworkErrorWithoutResponse) {
        switch error {
        case .invalidStatusCode(let code, _) where (500...599).contains(code):
            completion(.failure(.serverError))
            
        case .urlError(let error) where [.notConnectedToInternet, .cannotFindHost, .cannotConnectToHost].contains(error.code):
            completion(.failure(.noInternet))
            
        case .urlError(let error) where error.code == .timedOut:
            completion(.failure(.timeout))
            
        default:
            completion(.failure(.unknown))
        }
    }
}
