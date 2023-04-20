//
//  AnalyticsHTTPRequest.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation
import PaltaCore

enum AnalyticsHTTPRequest: Equatable {
    case remoteConfig(URL?, String)
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
        switch self {
        case .remoteConfig(let url, _), .sendEvents(let url, _):
            return url ?? URL(string: "https://api.paltabrain.com")!
        }
    }

    var path: String? {
        switch self {
        case .remoteConfig:
            return "/v1/config"
        case .sendEvents:
            return "/v2/amplitude"
        }
    }

    var cachePolicy: URLRequest.CachePolicy? {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    var headers: [String : String]? {
        switch self {
        case .remoteConfig(_, let apiKey):
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
