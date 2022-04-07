//
//  EventSender.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation
import PaltaLibCore

enum EventSendError: Error {
    case timeout
    case noInternet
    case serverError
    case badRequest
    case unknown

    var requiresRetry: Bool {
        switch self {
        case .timeout, .noInternet, .serverError:
            return true
        case .badRequest, .unknown:
            return false
        }
    }
}

protocol EventSender {
    func sendEvents(_ events: [Event], completion: @escaping (Result<(), EventSendError>) -> Void)
}

final class EventSenderImpl: EventSender {
    var apiToken: String?

    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func sendEvents(_ events: [Event], completion: @escaping (Result<(), EventSendError>) -> Void) {
        guard let apiToken = apiToken else {
            assertionFailure("Attempt to send event without API token")
            return
        }

        let request = AnalyticsHTTPRequest.sendEvents(
            SendEventsPayload(apiKey: apiToken, events: events)
        )

        httpClient.perform(request) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                EventSenderImpl.handleError(error, completion)
            }
        }
    }

    private static func handleError(_ error: Error, _ completion: @escaping (Result<(), EventSendError>) -> Void) {
        if let networkError = error as? URLError, [.notConnectedToInternet].contains(networkError.code) {
            completion(.failure(.noInternet))
        } else if let networkError = error as? URLError, [.timedOut].contains(networkError.code) {
            completion(.failure(.timeout))
        } else if let networkError = error as? URLError, (400...499).contains(networkError.code.rawValue) {
            completion(.failure(.badRequest))
        } else if let networkError = error as? URLError, (500...599).contains(networkError.code.rawValue) {
            completion(.failure(.serverError))
        } else {
            completion(.failure(.unknown))
        }
    }
}
