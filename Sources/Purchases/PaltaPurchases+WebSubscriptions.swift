import Foundation
import PaltaLibCore

extension PaltaPurchases {
    public func sendRestoreLink(to email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let webSubscriptionID = PaltaPurchases.webSubscriptionID else {
            fatalError("webSubscriptionID should be configured on launch")
        }

        let request = PurchaseHTTPRequest.restoreSubscription(
            RestoreRequestData(email: email, webSubscriptionID: webSubscriptionID)
        )

        httpClient.perform(request) { (result: Result<RestoreResponce, Error>) in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func cancelSubscription(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let webSubscriptionID = PaltaPurchases.webSubscriptionID else {
            fatalError("webSubscriptionID should be configured on launch")
        }

        let request = PurchaseHTTPRequest.cancelSubscription(
            CancelRequestData(revenueCatID: revenueCatID, webSubscriptionID: webSubscriptionID)
        )

        #warning("Need to use other success response type")
        httpClient.perform(request) { [unowned self] (result: Result<RestoreResponce, Error>) in
            switch result {
            case .success:
                self.invalidatePurchaserInfoCache()
                self.fetchPurchaserInfo { _ in
                    completion(.success(()))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private struct RestoreResponce: Decodable {
    let message: String
}
