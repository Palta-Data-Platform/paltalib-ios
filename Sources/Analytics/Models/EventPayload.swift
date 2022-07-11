//
//  EventPayload.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol EventPayload {
    
}

public protocol SessionStartEventPayload: EventPayload {
    init()
}

struct EventPayloadBox {
    private let internalBox: EventPayloadBoxInternalProtocol
    
    init<T: EventPayload>(_ eventPayload: T) {
        internalBox = EventPayloadBoxInternal(eventPayload)
    }
    
    func unbox<T: EventPayload>(as type: T.Type) -> T? {
        internalBox.unbox(as: T.self)
    }
}

private protocol EventPayloadBoxInternalProtocol {
    func unbox<T: EventPayload>(as type: T.Type) -> T?
}

private struct EventPayloadBoxInternal<Wrapped: EventPayload>: EventPayloadBoxInternalProtocol {
    private let eventPayload: Wrapped
    
    init(_ eventPayload: Wrapped) {
        self.eventPayload = eventPayload
    }
    
    func unbox<T: EventPayload>(as type: T.Type) -> T? {
        eventPayload as? T
    }
}
