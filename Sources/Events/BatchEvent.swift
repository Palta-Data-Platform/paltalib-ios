//
//  BatchEvent.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import PaltaLibAnalytics
import PaltaAnlyticsTransport

extension PaltaLibAnalytics.EventCommon {
    var message: PaltaAnlyticsTransport.EventCommon {
        var msg = PaltaAnlyticsTransport.EventCommon()
        msg.eventType = eventType.intValue
        msg.eventTs = Int64(timestamp)
        msg.sessionID = Int64(sessionId)
        return msg
    }
}

extension PaltaAnlyticsTransport.Event: BatchEvent {
    public init(data: Data) throws {
        try self.init(serializedData: data)
    }
    
    public var timestamp: Int {
        Int(common.eventTs)
    }
    
    public func serialize() throws -> Data {
        try self.serializedData()
    }
    
    public init(
        common: PaltaLibAnalytics.EventCommon,
        header: PaltaLibAnalytics.EventHeader,
        payload: PaltaLibAnalytics.EventPayload
    ) {
        guard
            let header = header as? EventHeader,
            let payload = payload as? PaltaAnlyticsTransport.EventPayload
        else {
            assertionFailure("Mixing up different protobufs")
            self = .init()
            return
        }
        
        self.init()
        
        self.common = common.message
        self.header = header.message
        self.payload = payload
    }
}

extension Int: EventType {
    public var intValue: Int64 {
        Int64(self)
    }
}

extension PaltaAnlyticsTransport.EventPayload: PaltaLibAnalytics.EventPayload {
}
