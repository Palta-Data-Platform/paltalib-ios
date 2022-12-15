//
//  BatchSender.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

import Foundation
import PaltaLibCore

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
    
    var baseURL: URL?
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func sendBatch(_ batch: Batch, completion: @escaping (Result<(), BatchSendError>) -> Void) {
        guard let apiToken = apiToken else {
            assertionFailure("Attempt to send event without API token")
            return
        }
        
        let errorHandler = ErrorHandler(completion: completion)

        let request = AnalyticsHTTPRequest.sendEvents(
            baseURL,
            SendEventsPayload(
                apiKey: apiToken,
                events: batch.events,
                serviceInfo: .init(
                    uploadTime: .currentTimestamp(),
                    library: .init(name: "PaltaBrain", version: "2.4.0"), // TODO: Auto update version
                    telemetry: batch.telemetry,
                    batchId: batch.batchId
                )
            )
        )

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
