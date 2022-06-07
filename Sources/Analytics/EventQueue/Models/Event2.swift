//
//  Event2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol Event2 {
    associatedtype Header: EventHeader
    associatedtype Payload: EventPayload
    associatedtype EventType: PaltaLibAnalytics.EventType
    
    var header: Header { get }
    var payload: Payload { get }
    var type: EventType { get }
}
