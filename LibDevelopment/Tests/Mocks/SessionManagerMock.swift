//
//  SessionManagerMock.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class SessionManagerMock: SessionManager {
    var sessionEventLogger: ((String, Int) -> Void)?

    var refreshSessionCalled = false
    var startCalled = false
    var startNewSessionCalled = false

    func refreshSession(with event: Event) {
        refreshSessionCalled = true
    }

    func start() {
        startCalled = true
    }

    func startNewSession() {
        startNewSessionCalled = true
    }


}
