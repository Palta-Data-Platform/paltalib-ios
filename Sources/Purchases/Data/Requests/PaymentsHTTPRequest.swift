//
//  PaymentsHTTPRequest.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import PaltaLibCore

enum PaymentsHTTPRequest {
    case getServices(UserId)
    case getSubcriptions(UserId, Set<UUID>?)
}

extension PaymentsHTTPRequest: CodableAutobuildingHTTPRequest {
    var bodyObject: AnyEncodable? {
        switch self {
        case let .getServices(userId):
            return GetServicesRequestPayload(customerId: userId).typeErased
            
        case let .getSubcriptions(userId, subscriptionIds):
            return GetSubscriptionsRequestPayload(customerId: userId, onlyIds: subscriptionIds).typeErased
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getSubcriptions, .getServices:
            return .post
        }
    }
    
    var baseURL: URL {
        URL(string: "https://example.com")!
    }
    
    var path: String? {
        switch self {
        case .getServices:
            return "/service-provisioner/get-services"
            
        case .getSubcriptions:
            return "/subscriptions-tracker/get-subscriptions"
        }
    }
}
