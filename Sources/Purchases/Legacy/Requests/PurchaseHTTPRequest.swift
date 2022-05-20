//
//  PurchaseHTTPRequest.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation
import PaltaLibCore

enum PurchaseHTTPRequest {
    case restoreSubscription(RestoreRequestData)
    case cancelSubscription(CancelRequestData)
}

extension PurchaseHTTPRequest: CodableAutobuildingHTTPRequest {
    var baseURL: URL {
        URL(string: "https://ws.prod.paltabrain.com")!
    }

    var method: HTTPMethod {
        switch self {
        case .restoreSubscription, .cancelSubscription:
            return .post
        }
    }

    var headers: [String : String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    var path: String? {
        switch self {
        case .restoreSubscription:
            return "/v1/send-restore-subscription-email"
        case .cancelSubscription:
            return "/v1/unsubscribe"
        }
    }

    var bodyObject: AnyEncodable? {
        switch self {
        case .restoreSubscription(let restoreRequestData):
            return restoreRequestData.typeErased
        case .cancelSubscription(let cancelRequestData):
            return cancelRequestData.typeErased
        }
    }

}

