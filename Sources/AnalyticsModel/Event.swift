//
//  Event.swift
//  PaltaLibAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol Event {
    associatedtype Header: EventHeader
    associatedtype Payload: EventPayload
    associatedtype EventType: PaltaLibAnalyticsModel.EventType
    
    var header: Header? { get }
    var payload: Payload { get }
    var type: EventType { get }
}
