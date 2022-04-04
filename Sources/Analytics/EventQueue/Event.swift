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
        case timestamp
    }

    let eventType: String
    let eventProperties: CodableDictionary
    let apiProperties: CodableDictionary
    let userProperties: CodableDictionary
    let groups: CodableDictionary
    let groupProperties: CodableDictionary
    let sessionId: Int
    let timestamp: Int
}
