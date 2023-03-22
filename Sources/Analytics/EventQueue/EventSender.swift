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
    func sendEvents(_ events: [Event], telemetry: Telemetry?, completion: @escaping (Result<(), EventSendError>) -> Void)
}

final class EventSenderImpl: EventSender {
    var apiToken: String?
    var baseURL: URL?

    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func sendEvents(
        _ events: [Event],
        telemetry: Telemetry?,
        completion: @escaping (Result<(), EventSendError>) -> Void
    ) {
        guard let apiToken = apiToken else {
            assertionFailure("Attempt to send event without API token")
            return
        }

        let request = AnalyticsHTTPRequest.sendEvents(
            baseURL,
            SendEventsPayload(
                apiKey: apiToken,
                events: events,
                serviceInfo: .init(
                    uploadTime: .currentTimestamp(),
                    library: .init(name: "PaltaBrain", version: "2.2.5"), // TODO: Auto update version
                    telemetry: telemetry
                )
            )
        )

        httpClient.perform(request) { (result: Result<EmptyResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                EventSenderImpl.handleError(error, completion)
            }
        }
    }

    private static func handleError(
        _ error: NetworkErrorWithoutResponse,
        _ completion: @escaping (Result<(), EventSendError>) -> Void
    ) {
        switch error {
        case .urlError(let error) where error.code == .notConnectedToInternet:
            completion(.failure(.noInternet))
        case .urlError(let error) where error.code == .timedOut:
            completion(.failure(.timeout))
        case .invalidStatusCode(let code, _) where (400...499).contains(code):
            completion(.failure(.badRequest))
        case .invalidStatusCode(let code, _) where (500...599).contains(code):
            completion(.failure(.serverError))
        default:
            completion(.failure(.unknown))
        }
    }
}
