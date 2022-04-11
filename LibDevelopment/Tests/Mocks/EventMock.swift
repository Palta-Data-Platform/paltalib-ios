//
//  EventMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 01.04.2022.
//

import Foundation
@testable import PaltaLibAnalytics

extension Event {
    static func mock(timestamp: Int? = nil) -> Event {
        Event(
            eventType: "event",
            eventProperties: [:],
            apiProperties: [:],
            userProperties: [:],
            groups: [:],
            groupProperties: [:],
            sessionId: 1,
            timestamp: timestamp ?? .currentTimestamp(),
            userId: nil,
            deviceId: nil,
            platform: nil,
            appVersion: nil,
            osName: nil,
            osVersion: nil,
            deviceModel: nil,
            deviceManufacturer: nil,
            carrier: nil,
            country: nil,
            language: nil,
            timezone: "GMT+X"
        )
    }
}
