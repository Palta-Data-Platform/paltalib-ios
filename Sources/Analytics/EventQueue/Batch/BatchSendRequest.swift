//
//  BatchSendRequest.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaLibCore

struct BatchSendRequest {
    let host: URL?
    let time: Int
    let data: Data
}

extension BatchSendRequest: AutobuildingHTTPRequest {
    var method: HTTPMethod {
        .post
    }
    
    var baseURL: URL {
        host ?? Constants.defaultBaseURL
    }
    
    var path: String? {
        "/batch-send"
    }
    
    var headers: [String : String]? {
        [
            "X-Client-Upload-TS": "\(time)",
            "Content-Type": "application/protobuf"
        ]
    }
    
    var body: Data? {
        data
    }
}
