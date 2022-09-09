//
//  EventPayload.swift
//  PaltaLibAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol EventPayload {
    
}

public protocol SessionStartEventPayload: EventPayload {
    init()
}
