//
//  BatchSendRequest.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaLibCore

struct BatchSendRequest {
    let url: URL
    let time: Int
    let data: Data
}

extension BatchSendRequest: AutobuildingHTTPRequest {
    var method: HTTPMethod {
        .post
    }
    
    var baseURL: URL {
        url
    }
    
    var path: String? {
        nil
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
