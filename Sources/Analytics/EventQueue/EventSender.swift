//
//  EventSender.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation
import PaltaCore

extension CategorisedNetworkError {
    var requiresRetry: Bool {
        switch self {
        case .timeout, .noInternet, .serverError, .requiresHttps, .dnsError, .sslError, .otherNetworkError,
                .decodingError, .badResponse, .cantConnectToHost, .notConfigured:
            return true
        case .badRequest, .unknown, .unauthorised, .clientError:
            return false
        }
    }
    
    var canRetryIndefinetely: Bool {
        switch self {
        case .notConfigured, .requiresHttps, .noInternet, .cantConnectToHost:
            return true
        default:
            return false
        }
    }
}

protocol EventSender {
    func sendEvents(_ events: [Event], telemetry: Telemetry?, completion: @escaping (Result<(), CategorisedNetworkError>) -> Void)
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
        completion: @escaping (Result<(), CategorisedNetworkError>) -> Void
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
        _ completion: @escaping (Result<(), CategorisedNetworkError>) -> Void
    ) {
        completion(.failure(CategorisedNetworkError(error)))
    }
}
