//
//  Event.swift
//  
//
//  Created by Vyacheslav Beltyukov on 31.03.2022.
//

import Foundation
import PaltaLibCore

struct Event: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case eventType = "event_type"
        case eventProperties = "event_properties"
        case apiProperties = "api_properties"
        case userProperties = "user_properties"
        case groups
        case groupProperties = "group_properties"
        case sessionId = "session_id"
        case timestamp = "time"
        case userId = "user_id"
        case deviceId = "device_id"
        case platform
        case appVersion = "version_name"
        case osName = "os_name"
        case osVersion = "os_version"
        case deviceModel = "device_model"
        case deviceManufacturer = "device_manufacturer"
        case carrier
        case country
        case language
        case timezone
        case library
        case uuid
        case sequenceNumber = "sequence_number"
    }

    struct Library: Codable, Hashable {
        let name: String
        let version: String
    }

    let eventType: String
    let eventProperties: CodableDictionary
    let apiProperties: CodableDictionary
    let userProperties: CodableDictionary
    let groups: CodableDictionary
    let groupProperties: CodableDictionary
    let sessionId: Int
    let timestamp: Int
    let userId: String?
    let deviceId: String?
    let platform: String?
    let appVersion: String?
    let osName: String?
    let osVersion: String?
    let deviceModel: String?
    let deviceManufacturer: String?
    let carrier: String?
    let country: String?
    let language: String?
    let timezone: String
    let library: Library
    let uuid: UUID
    let sequenceNumber: Int
}
