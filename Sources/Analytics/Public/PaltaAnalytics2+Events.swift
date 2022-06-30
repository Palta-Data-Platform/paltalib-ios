//
//  PaltaAnalytics2+Events.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation

public extension PaltaAnalytics2 {
    func log<E: Event2>(_ event: E, outOfSession: Bool = false) {
        assembly.eventQueueAssembly.eventQueue.logEvent(event, outOfSession: outOfSession)
    }
}
