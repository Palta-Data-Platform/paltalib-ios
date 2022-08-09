//
//  GetConfigRequest.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation
import PaltaLibCore

struct GetConfigRequest: Equatable {
    let host: URL?
    let apiKey: String
}

extension GetConfigRequest: AutobuildingHTTPRequest {
    var method: HTTPMethod {
        .get
    }

    var baseURL: URL {
        host ?? URL(string: "https://api.paltabrain.com")!
    }

    var path: String? {
        "/v2/config"
    }

    var cachePolicy: URLRequest.CachePolicy? {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    var headers: [String : String]? {
        ["X-API-Key": apiKey]
    }

    var timeout: TimeInterval? {
        10
    }
}
