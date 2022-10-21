//
//  BatchComposerMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 21/10/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class BatchComposerMock: BatchComposer {
    var events: [Event]?
    var telemetry: Telemetry?
    
    func makeBatch(of events: [Event], telemetry: Telemetry) -> Batch {
        self.events = events
        self.telemetry = telemetry
        
        return .mock()
    }
}
