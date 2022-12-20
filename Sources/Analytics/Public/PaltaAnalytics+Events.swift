//
//  PaltaAnalytics2+Events.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel

public extension PaltaAnalytics {
    func log<E: Event>(_ event: E) {
        assembly?.eventQueueAssembly.eventQueue.logEvent(event)
    }
}
