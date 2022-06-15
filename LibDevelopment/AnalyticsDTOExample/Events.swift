//
//  Events.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import PaltaLibAnalytics
import ProtobufExample

extension Int: EventType {
    
}

extension ProtobufExample.EventPayload: PaltaLibAnalytics.EventPayload {}

public struct PageOpenEvent: Event2 {
    public typealias Header = AnalyticsDTOExample.Header
    public typealias Payload = ProtobufExample.EventPayload
    public typealias EventType = Int
    
    private let _payload: EventPayloadPageOpen
    
    public init(header: Header, pageID: String, title: String) {
        _payload = EventPayloadPageOpen.with {
            $0.pageID = pageID
            $0.title = title
        }
    }
    
    public var header: Header {
        fatalError()
    }
    
    public var payload: Payload {
        ProtobufExample.EventPayload.with {
            $0.event1 = _payload
        }
    }
    
    public var type: EventType {
        1
    }
}
