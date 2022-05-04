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

        httpClient.perform(request) { (result: Result<RestoreResponce, NetworkErrorWithResponse<ErrorResponse>>) in
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

        #warning("Need to use other success response type")
        httpClient.perform(request) { [unowned self] (result: Result<RestoreResponce, NetworkErrorWithResponse<ErrorResponse>>) in
            switch result {
            case .success:
                self.invalidatePurchaserInfoCache()
                self.fetchPurchaserInfo { _ in
                    completion(.success(()))
                }
            case let .failure(error):
                PaltaPurchases.handleError(error, completion: completion)
            }
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

private struct RestoreResponce: Decodable {
    let message: String
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
