//
//  IdentifiableEvent.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 20/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel

struct IdentifiableEvent {
    let id: UUID
    let event: BatchEvent
}
