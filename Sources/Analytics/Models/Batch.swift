//
//  Batch.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

import Foundation

struct Batch: Codable, Equatable {
    let events: [Event]
    let telemetry: Telemetry
}
