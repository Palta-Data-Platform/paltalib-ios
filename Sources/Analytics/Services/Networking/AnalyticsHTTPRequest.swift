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
}

extension AnalyticsHTTPRequest: CodableAutobuildingHTTPRequest {
    var method: HTTPMethod {
        switch self {
        case .remoteConfig:
            return .get
        }
    }

    var baseURL: URL {
        URL(string: "https://api.paltabrain.com")!
    }

    var path: String? {
        switch self {
        case .remoteConfig:
            return "/v1/config"
        }
    }

    var cachePolicy: URLRequest.CachePolicy? {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    var headers: [String : String]? {
        switch self {
        case .remoteConfig(let apiKey):
            return ["X-API-Key": apiKey]
        }
    }

    var timeout: TimeInterval? {
        switch self {
        case .remoteConfig:
            return 10
        }
    }

    var bodyObject: AnyEncodable? {
        switch self {
        case .remoteConfig:
            return nil
        }
    }
}
