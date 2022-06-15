//
//  BatchSendRequest.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaLibCore

struct BatchSendRequest {
    let sdkName: String
    let sdkVersion: String
    let time: Int
    let data: Data
}

extension BatchSendRequest: AutobuildingHTTPRequest {
    var method: HTTPMethod {
        .post
    }
    
    var baseURL: URL {
        URL(string: "https://api.paltabrain.com")!
    }
    
    var path: String? {
        "/batch-proto"
    }
    
    var headers: [String : String]? {
        [
            "X-SDK-Name": sdkName,
            "X-SDK-Version": sdkVersion,
            "X-Client-Upload-TS": "\(time)",
            "Content-Type": "application/protobuf"
        ]
    }
    
    var body: Data? {
        data
    }
}
