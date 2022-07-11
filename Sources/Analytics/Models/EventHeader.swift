//
//  EventHeader.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol EventHeader {
    init()
}

struct EventHeaderBox {
    private let internalBox: EventHeaderBoxInternalProtocol
    
    init<T: EventHeader>(_ eventHeader: T) {
        internalBox = EventHeaderBoxInternal(eventHeader)
    }
    
    func unbox<T: EventHeader>(as type: T.Type) -> T? {
        internalBox.unbox(as: T.self)
    }
}

private protocol EventHeaderBoxInternalProtocol {
    func unbox<T: EventHeader>(as type: T.Type) -> T?
}

private struct EventHeaderBoxInternal<Wrapped: EventHeader>: EventHeaderBoxInternalProtocol {
    private let eventHeader: Wrapped
    
    init(_ eventHeader: Wrapped) {
        self.eventHeader = eventHeader
    }
    
    func unbox<T: EventHeader>(as type: T.Type) -> T? {
        eventHeader as? T
    }
}

