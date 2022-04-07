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
    }

    let apiKey: String
    let events: [Event]
}
