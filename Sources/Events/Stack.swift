//
//  Stack.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import PaltaLibAnalytics
import PaltaAnlyticsTransport

public extension Stack {
    static let `default` = Stack(
        batchCommon: PaltaAnlyticsTransport.BatchCommon.self,
        context: Context.self,
        batch: PaltaAnlyticsTransport.Batch.self,
        event: PaltaAnlyticsTransport.Event.self,
        sessionStartEventType: 1,
        eventHeader: EventHeader.self,
        sessionStartEventPayload: EventPayload.self
    )
}
