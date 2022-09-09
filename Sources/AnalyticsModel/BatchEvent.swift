//
//  BatchEvent.swift
//  PaltaLibAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol BatchEvent {
    var timestamp: Int { get }

    init(common: EventCommon, header: EventHeader?, payload: EventPayload)
    init(data: Data) throws
    
    func serialize() throws -> Data
}
