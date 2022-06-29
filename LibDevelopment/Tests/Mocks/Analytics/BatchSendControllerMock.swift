//
//  BatchSendControllerMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class BatchSendControllerMock: BatchSendController {
    var isReady: Bool = false
    var isReadyCallback: (() -> Void)?
    
    var sentEvents: [BatchEvent]?
    var contextId: UUID?
    
    func sendBatch(of events: [BatchEvent], with contextId: UUID) {
        self.sentEvents = events
        self.contextId = contextId
    }
}
