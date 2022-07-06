//
//  SendEventsPayload.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07.04.2022.
//

import Foundation

struct SendEventsPayload: Encodable, Equatable {
    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case events
        case serviceInfo = "paltabrain"
    }

    struct ServiceInfo: Encodable, Equatable {
        struct Library: Codable, Hashable {
            let name: String
            let version: String
        }
        
        enum CodingKeys: String, CodingKey {
            case uploadTime = "client_upload_time"
            case library
            case telemetry
        }
        
        let uploadTime: Int
        let library: Library
        let telemetry: Telemetry?
    }

    let apiKey: String
    let events: [Event]
    let serviceInfo: ServiceInfo
}
