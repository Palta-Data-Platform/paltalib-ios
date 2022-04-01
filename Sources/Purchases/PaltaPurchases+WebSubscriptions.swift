import Foundation
import PaltaLibCore

extension PaltaPurchases {
    public func sendRestoreLink(to email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let webSubscriptionID = PaltaPurchases.webSubscriptionID else {
            fatalError("webSubscriptionID should be configured on launch")
        }

        let request = HTTPRequest.restoreRequest(withEmail: email,
                                                 webSubscriptionID: webSubscriptionID)
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

        let request = HTTPRequest.cancelSubscriptionRequest(withRevenueCatID: revenueCatID,
                                                            webSubscriptionID: webSubscriptionID)
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

private extension HTTPRequest {
    static func restoreRequest(withEmail email: String,
                               webSubscriptionID: String) -> HTTPRequest {
        let bodyJSON = ["email": email,
                        "web_subscription_id": webSubscriptionID]
        guard JSONSerialization.isValidJSONObject(bodyJSON),
              let data = try? JSONSerialization.data(withJSONObject: bodyJSON, options: [])
        else {
            fatalError()
        }

        return HTTPRequest(method: .post,
                           path: "/v1/send-restore-subscription-email",
                           body: data)
    }

    static func cancelSubscriptionRequest(withRevenueCatID revenueCatID: String,
                                          webSubscriptionID: String) -> HTTPRequest {
        let bodyJSON = ["revenue_cat_id": revenueCatID,
                        "web_subscription_id": webSubscriptionID]
        guard JSONSerialization.isValidJSONObject(bodyJSON),
              let data = try? JSONSerialization.data(withJSONObject: bodyJSON, options: [])
        else {
            fatalError()
        }

        return HTTPRequest(method: .post,
                           path: "/v1/unsubscribe",
                           body: data)
    }
}

private struct RestoreResponce: Decodable {
    let message: String
}
