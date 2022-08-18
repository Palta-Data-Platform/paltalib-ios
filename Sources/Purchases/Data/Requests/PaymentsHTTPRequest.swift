//
//  PaymentsHTTPRequest.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import PaltaLibCore

enum PaymentsHTTPRequest: Equatable {
    case getFeatures(Environment, UserId)
    case getSubcriptions(Environment, UserId, Set<UUID>?)
    case getShowcase(Environment, UserId, String?)
}

extension PaymentsHTTPRequest: CodableAutobuildingHTTPRequest {
    var environment: Environment {
        switch self {
        case .getFeatures(let environemt, _):
            return environemt
        case .getSubcriptions(let environemt, _, _):
            return environemt
        case .getShowcase(let environment, _, _):
            return environment
        }
    }
    var bodyObject: AnyEncodable? {
        switch self {
        case let .getFeatures(_, userId):
            return GetFeaturesRequestPayload(customerId: userId).typeErased
            
        case let .getSubcriptions(_, userId, subscriptionIds):
            return GetSubscriptionsRequestPayload(customerId: userId, onlyIds: subscriptionIds).typeErased
            
        case let .getShowcase(_, userId, countryCode):
            return GetShowcaseRequestPayload(customerId: userId, countryCode: countryCode).typeErased
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getSubcriptions, .getFeatures, .getShowcase:
            return .post
        }
    }
    
    var baseURL: URL {
        switch environment {
        case .prod:
            return URL(string: "https://api.payments.paltabrain.com")!
        case .dev:
            return URL(string: "https://api.payments.dev.paltabrain.com")!
        }
    }
    
    var path: String? {
        switch self {
        case .getFeatures:
            return "/feature-provisioner/get-features"
            
        case .getSubcriptions:
            return "/subscriptions-tracker/get-subscriptions"
            
        case .getShowcase:
            return "/showcase/get-price-points"
        }
    }
}
