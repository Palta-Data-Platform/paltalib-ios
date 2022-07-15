//
//  SessionManagerMock.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import Foundation
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class SessionManagerMock: SessionManager, SessionIdProvider {
    var sessionId: Int = -1
    var sessionStartLogger: (() -> Void)?

    var refreshSessionCalled = false
    var startCalled = false
    var startNewSessionCalled = false
    
    func refreshSession(with event: BatchEvent) {
        refreshSessionCalled = true
    }

    func start() {
        startCalled = true
    }

    func startNewSession() {
        startNewSessionCalled = true
    }


}
