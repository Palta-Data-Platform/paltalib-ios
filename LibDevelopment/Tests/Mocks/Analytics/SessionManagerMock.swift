//
//  SessionManagerMock.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import Foundation
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class SessionManagerMock: SessionManager, SessionProvider {
    var sessionId: Int = -1
    var sessionStartLogger: ((Int) -> Void)?

    var refreshSessionCalled = false
    var startCalled = false
    var startNewSessionCalled = false
    
    var eventNumber: Int = .random(in: 0...10000)
    
    func refreshSession(with timestamp: Int) {
        refreshSessionCalled = true
    }
    
    func nextEventNumber() -> Int {
        eventNumber
    }

    func start() {
        startCalled = true
    }
}
