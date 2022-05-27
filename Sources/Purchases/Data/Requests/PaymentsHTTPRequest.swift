//
//  PaymentsHTTPRequest.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import PaltaLibCore

enum PaymentsHTTPRequest: Equatable {
    case getFeatures(UserId)
    case getSubcriptions(UserId, Set<UUID>?)
}

extension PaymentsHTTPRequest: CodableAutobuildingHTTPRequest {
    var bodyObject: AnyEncodable? {
        switch self {
        case let .getFeatures(userId):
            return GetFeaturesRequestPayload(customerId: userId).typeErased
            
        case let .getSubcriptions(userId, subscriptionIds):
            return GetSubscriptionsRequestPayload(customerId: userId, onlyIds: subscriptionIds).typeErased
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getSubcriptions, .getFeatures:
            return .post
        }
    }
    
    var baseURL: URL {
        URL(string: "https://example.com")!
    }
    
    var path: String? {
        switch self {
        case .getFeatures:
            return "/service-provisioner/get-services"
            
        case .getSubcriptions:
            return "/subscriptions-tracker/get-subscriptions"
        }
    }
}
