import Foundation
import PaltaLibCore

extension PaltaPurchases {
    public func sendRestoreLink(to email: String, completion: @escaping (Result<Void, WebSubscriptionError>) -> Void) {
        guard let webSubscriptionID = PaltaPurchases.webSubscriptionID else {
            fatalError("webSubscriptionID should be configured on launch")
        }

        let request = PurchaseHTTPRequest.restoreSubscription(
            RestoreRequestData(email: email, webSubscriptionID: webSubscriptionID)
        )

        httpClient.perform(request) { (result: Result<WebSubscriptionsResponse, NetworkErrorWithResponse<ErrorResponse>>) in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                PaltaPurchases.handleError(error, completion: completion)
            }
        }
    }

    public func cancelSubscription(completion: @escaping (Result<Void, WebSubscriptionError>) -> Void) {
        guard let webSubscriptionID = PaltaPurchases.webSubscriptionID else {
            fatalError("webSubscriptionID should be configured on launch")
        }

        let request = PurchaseHTTPRequest.cancelSubscription(
            CancelRequestData(revenueCatID: revenueCatID, webSubscriptionID: webSubscriptionID)
        )

        httpClient.perform(request) { [unowned self] (result: Result<WebSubscriptionsResponse, NetworkErrorWithResponse<ErrorResponse>>) in
            switch result {
            case let .success(response) where response.message == .redirect:
                guard let url = response.url else {
                    completion(.failure(.networkError(.decodingError(nil))))
                    return
                }
                
                delegate?.paltaPurchases(self, needsToOpenURL: url) { [unowned self] in
                    completeCancel(completion: completion)
                }
            case .success:
                completeCancel(completion: completion)
            case let .failure(error):
                PaltaPurchases.handleError(error, completion: completion)
            }
        }
    }
    
    private func completeCancel(completion: @escaping (Result<Void, WebSubscriptionError>) -> Void) {
        self.invalidatePurchaserInfoCache()
        self.fetchPurchaserInfo { _ in
            completion(.success(()))
        }
    }

    private static func handleError<T>(
        _ error: NetworkErrorWithResponse<ErrorResponse>,
        completion: @escaping (Result<T, WebSubscriptionError>) -> Void
    ) {
        if case let .invalidStatusCode(_, response) = error {
            completion(.failure(response?.asWebSubscriptionError ?? .networkError(NetworkError(error))))
        } else {
            completion(.failure(.networkError(NetworkError(error))))
        }
    }
}

private struct WebSubscriptionsResponse: Decodable {
    enum Message: String, Decodable {
        case ok = "OK"
        case redirect = "Redirect"
    }
    
    let message: Message
    let url: URL?
}

private struct ErrorResponse: Decodable {
    enum Error: String, Decodable {
        case noUserFound = "Can't find user"
    }

    let error: Error

    var asWebSubscriptionError: WebSubscriptionError? {
        switch error {
        case .noUserFound:
            return .noUserFound
        }
    }
}
