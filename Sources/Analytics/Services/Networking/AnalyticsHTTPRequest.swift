//
//  AnalyticsHTTPRequest.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation
import PaltaLibCore

enum AnalyticsHTTPRequest: Equatable {
    case remoteConfig(String)
    case sendEvents(SendEventsPayload)
}

extension AnalyticsHTTPRequest: CodableAutobuildingHTTPRequest {
    var method: HTTPMethod {
        switch self {
        case .remoteConfig:
            return .get
        case .sendEvents:
            return .post
        }
    }

    var baseURL: URL {
        URL(string: "https://api.paltabrain.com")!
    }

    var path: String {
        switch self {
        case .remoteConfig:
            return "/v1/config"
        case .sendEvents:
            return "/events-v2"
        }
    }

    var cachePolicy: URLRequest.CachePolicy? {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    var headers: [String : String]? {
        switch self {
        case .remoteConfig(let apiKey):
            return ["X-API-Key": apiKey]

        case .sendEvents(let payload):
            return [
                "X-API-Key": payload.apiKey,
                "Content-Type": "application/json"
            ]
        }
    }

    var timeout: TimeInterval? {
        switch self {
        case .remoteConfig:
            return 10
        case .sendEvents:
            return 30
        }
    }

    var queryParameters: [String : String]? {
        switch self {
        case .remoteConfig:
            return nil
        case .sendEvents(let payload):
            return ["client": payload.apiKey]
        }
    }

    var bodyObject: AnyEncodable? {
        switch self {
        case .remoteConfig:
            return nil
        case .sendEvents(let sendEventsPayload):
            return sendEventsPayload.typeErased
        }
    }
}
