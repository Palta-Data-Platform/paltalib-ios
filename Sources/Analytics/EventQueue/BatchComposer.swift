//
//  BatchComposer.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

import Foundation
import PaltaLibAnalyticsModel

protocol BatchComposer {
    func makeBatch(of events: [Event], telemetry: Telemetry) -> Batch
}

final class BatchComposerImpl: BatchComposer {
    func makeBatch(of events: [Event], telemetry: Telemetry) -> Batch {
        Batch(
            batchId: UUID(),
            events: events.sorted(by: { $0.timestamp < $1.timestamp }),
            telemetry: telemetry
        )
    }
}
