//
//  BatchEvent.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import PaltaLibAnalytics
import ProtobufExample

extension PaltaLibAnalytics.EventCommon {
    var message: ProtobufExample.EventCommon {
        var msg = ProtobufExample.EventCommon()
//        msg.eventType = even
        msg.eventTs = Int64(timestamp)
        msg.sessionID = Int64(sessionId)
        return msg
    }
}

extension Event: BatchEvent {
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
            let header = header as? ProtobufExample.EventHeader,
            let payload = payload as? ProtobufExample.EventPayload
        else {
            assertionFailure("Mixing up different protobufs")
            self = .init()
            return
        }
        
        self.init()
        
        self.common = common.message
        self.header = header
        self.payload = payload
    }
}
