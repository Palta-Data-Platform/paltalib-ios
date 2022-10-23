//
//  BatchSendControllerMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 21/10/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class BatchSendControllerMock: BatchSendController {
    var isReady: Bool = false
    var isReadyCallback: (() -> Void)?
    
    var sentEvents: [Event]?
    var telemetry: Telemetry?
    
    func sendBatch(of events: [Event], with telemetry: Telemetry) {
        self.sentEvents = events
        self.telemetry = telemetry
    }
}
