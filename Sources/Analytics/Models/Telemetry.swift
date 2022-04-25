//
//  Telemetry.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 25.04.2022.
//

import Foundation

struct Telemetry: Encodable, Equatable {
    let eventsInBatch: Int
    let batchLoad: Double
    let eventsDroppedSinceLastBatch: Int
}
