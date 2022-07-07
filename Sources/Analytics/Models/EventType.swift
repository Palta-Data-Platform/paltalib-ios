//
//  EventType.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol EventType {
    
}

extension EventType {
    var boxed: EventTypeBox {
        EventTypeBox(self)
    }
}

public struct EventTypeBox {
    private let internalBox: EventTypeBoxInternalProtocol
    
    init<T: EventType>(_ eventType: T) {
        internalBox = EventTypeBoxInternal(eventType)
    }
    
    func unbox<T: EventType>(as type: T.Type) -> T? {
        internalBox.unbox(as: T.self)
    }
}

private protocol EventTypeBoxInternalProtocol {
    func unbox<T: EventType>(as type: T.Type) -> T?
}

private struct EventTypeBoxInternal<Wrapped: EventType>: EventTypeBoxInternalProtocol {
    private let eventType: Wrapped
    
    init(_ eventType: Wrapped) {
        self.eventType = eventType
    }
    
    func unbox<T: EventType>(as type: T.Type) -> T? {
        eventType as? T
    }
}
