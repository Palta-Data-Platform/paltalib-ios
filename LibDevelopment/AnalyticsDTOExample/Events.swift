//
//  Events.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import PaltaLibAnalytics
import ProtobufExample

extension Int: EventType {
    public var intValue: Int64 {
        Int64(self)
    }
}

extension ProtobufExample.EventPayload: PaltaLibAnalytics.SessionStartEventPayload {}

public struct PageOpenEvent: PaltaLibAnalytics.Event {
    public typealias Header = AnalyticsDTOExample.Header
    public typealias Payload = ProtobufExample.EventPayload
    public typealias EventType = Int
    
    private let _payload: EventPayloadPageOpen
    
    public init(header: Header, pageID: String, title: String) {
        self.header = header
        self._payload = EventPayloadPageOpen.with {
            $0.pageID = pageID
            $0.title = title
        }
    }
    
    public let header: Header
    
    public var payload: Payload {
        ProtobufExample.EventPayload.with {
            $0.event1 = _payload
        }
    }
    
    public var type: EventType {
        1
    }
}
