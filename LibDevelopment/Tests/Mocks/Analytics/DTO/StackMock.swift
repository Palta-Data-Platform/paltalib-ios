//
//  StackMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 24/06/2022.
//

import Foundation
import PaltaLibAnalytics
import PaltaLibAnalyticsModel

extension Int: EventType {
    public var intValue: Int64 {
        1
    }
}

extension Stack {
    static let mock = Stack(
        batchCommon: BatchCommonMock.self,
        context: BatchContextMock.self,
        batch: BatchMock.self,
        event: BatchEventMock.self,
        sessionStartEventType: 1,
        eventHeader: EventHeaderMock.self,
        sessionStartEventPayloadProvider: { EventPayloadMock() }
    )
}
