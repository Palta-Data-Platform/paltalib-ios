//
//  PaymentsHTTPRequest.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import PaltaLibCore

struct PaymentsHTTPRequest: Equatable {
    enum Endpoint: Equatable {
        case getFeatures(UserId)
        case getSubcriptions(UserId, Set<UUID>?)
        case getShowcase(UserId, String?)
        case startCheckout(UserId)
        case checkoutCompleted(UUID, String)
        case checkoutFailed(UUID)
        case getCheckout(UUID)
        case log(LogPayload.Level, String, CodableDictionary?)
    }
    
    let environment: Environment
    let traceId: UUID
    let endpoint: Endpoint
}

extension PaymentsHTTPRequest: CodableAutobuildingHTTPRequest {
    var bodyObject: AnyEncodable? {
        switch endpoint {
        case let .getFeatures(userId):
            return GetFeaturesRequestPayload(customerId: userId).typeErased
            
        case let .getSubcriptions(userId, subscriptionIds):
            return GetSubscriptionsRequestPayload(customerId: userId, onlyIds: subscriptionIds).typeErased
            
        case let .getShowcase(userId, countryCode):
            return GetShowcaseRequestPayload(customerId: userId, countryCode: countryCode).typeErased
            
        case let .startCheckout(userId):
            return StartCheckoutRequestPayload(customerId: userId).typeErased
            
        case let .checkoutCompleted(orderId, receipt):
            return CheckoutCompletedRequestPayload(orderId: orderId, receipt: receipt).typeErased
            
        case let .checkoutFailed(orderId):
            return CheckoutFailedRequestPayload(orderId: orderId).typeErased
            
        case let .getCheckout(orderId):
            return GetCheckoutRequestPayload(orderId: orderId).typeErased
            
        case let .log(level, event, data):
            return LogPayload(level: level, eventName: event, data: data ?? [:]).typeErased
        }
    }
    
    var headers: [String : String]? {
        [
            "x-paltabrain-trace-id": traceId.uuidString,
            "Content-Type": "application/json"
        ]
    }
    
    var method: HTTPMethod {
        switch endpoint {
        case .getSubcriptions, .getFeatures, .getShowcase, .startCheckout, .checkoutCompleted, .checkoutFailed, .getCheckout, .log:
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
        switch endpoint {
        case .getFeatures:
            return "/feature-provisioner/get-features"
            
        case .getSubcriptions:
            return "/subscriptions-tracker/get-subscriptions"
            
        case .getShowcase:
            return "/showcase/get-price-points"
            
        case .startCheckout:
            return "/apple-store/start-checkout"
            
        case .checkoutCompleted:
            return "/apple-store/checkout-completed"
            
        case .checkoutFailed:
            return "/apple-store/checkout-failed"
            
        case .getCheckout:
            return "/apple-store/get-checkout"
            
        case .log:
            return "/apple-store/log-event"
        }
    }
    
    var timeout: TimeInterval? {
        switch endpoint {
        case .getCheckout:
            return 300
            
        default:
            return nil
        }
    }
}
