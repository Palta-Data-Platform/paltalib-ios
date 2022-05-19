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
    case sendEvents(URL?, SendEventsPayload)
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
        guard case let .sendEvents(url, _) = self, let url = url else {
            return URL(string: "https://api.paltabrain.com")!
        }
        
        return url
    }

    var path: String? {
        switch self {
        case .remoteConfig:
            return "/v1/config"
        case .sendEvents(let url, _) where url == nil:
            return "/events-v2"
        case .sendEvents:
            return nil
        }
    }

    var cachePolicy: URLRequest.CachePolicy? {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    var headers: [String : String]? {
        switch self {
        case .remoteConfig(let apiKey):
            return ["X-API-Key": apiKey]

        case .sendEvents(_, let payload):
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

    var bodyObject: AnyEncodable? {
        switch self {
        case .remoteConfig:
            return nil
        case .sendEvents(_, let sendEventsPayload):
            return sendEventsPayload.typeErased
        }
    }
}
