//
//  SessionManagerTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import XCTest
import Foundation
@testable import PaltaLibAnalytics

final class SessionManagerTests: XCTestCase {
    var userDefaults: UserDefaults!
    var notificationCenter: NotificationCenter!

    var sessionManager: SessionManagerImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        userDefaults = UserDefaults()
        notificationCenter = NotificationCenter()

        userDefaults.set(nil, forKey: "paltaBrainSession")

        sessionManager = SessionManagerImpl(userDefaults: userDefaults, notificationCenter: notificationCenter)
    }

    func testRestoreSession() {
        let session = Session(id: 22, currentEventNumber: 5)
        userDefaults.set(try! JSONEncoder().encode(session), forKey: "paltaBrainSession")

        let newSessionLogged = expectation(description: "New session logged")
        newSessionLogged.isInverted = true

        sessionManager.sessionStartLogger = { _ in
            newSessionLogged.fulfill()
        }
        sessionManager.start()

        wait(for: [newSessionLogged], timeout: 0.05)
        XCTAssertEqual(sessionManager.sessionId, session.id)
        XCTAssertEqual(sessionManager.nextEventNumber(), 6)
    }

    func testNoSavedSession() {
        let newSessionLogged = expectation(description: "New session logged")
        
        mockedTimestamp = 890

        sessionManager.sessionStartLogger = { timestamp in
            XCTAssertEqual(timestamp, 890)
            newSessionLogged.fulfill()
        }
        sessionManager.start()

        wait(for: [newSessionLogged], timeout: 0.05)
        
        XCTAssertEqual(sessionManager.sessionId, 890)
        
        XCTAssertEqual(sessionManager.nextEventNumber(), 0)
    }

    func testExpiredSession() throws {
        var session = Session(id: 22)
        session.lastEventTimestamp = 10
        userDefaults.set(try JSONEncoder().encode(session), forKey: "paltaBrainSession")

        let newSessionLogged = expectation(description: "New session logged")
        
        mockedTimestamp = 10_000_000

        sessionManager.sessionStartLogger = { timestamp in
            XCTAssertEqual(timestamp, 10_000_000)
            newSessionLogged.fulfill()
        }
        sessionManager.start()

        wait(for: [newSessionLogged], timeout: 0.05)
        
        XCTAssertEqual(sessionManager.nextEventNumber(), 0)
    }

    func testAppBecomeActive() {
        let newSessionLogged = expectation(description: "New session logged")
        
        mockedTimestamp = 25088

        sessionManager.sessionStartLogger = { timestamp in
            XCTAssertEqual(timestamp, 25088)
            newSessionLogged.fulfill()
        }

        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        wait(for: [newSessionLogged], timeout: 0.05)
        
        XCTAssertEqual(sessionManager.nextEventNumber(), 0)
    }

    func testRefreshSessionValid() throws {
        let initialSessionId = sessionManager.sessionId
        sessionManager.maxSessionAge = 100
        mockedTimestamp = initialSessionId + 5
        
        sessionManager.refreshSession(with: 0)

        let session = try userDefaults
            .data(forKey: "paltaBrainSession")
            .map { try JSONDecoder().decode(Session.self, from: $0) }
        
        XCTAssertEqual(sessionManager.sessionId, initialSessionId)
        XCTAssertEqual(session?.id, initialSessionId)
        XCTAssertEqual(session?.lastEventTimestamp, 0)
    }
    
    func testRefreshSessionInvalidWithinForeground() throws {
        let initialSessionId = sessionManager.sessionId
        sessionManager.maxSessionAge = 1
        mockedTimestamp = initialSessionId + 1005
        
        sessionManager.refreshSession(with: mockedTimestamp!)

        let session = try userDefaults
            .data(forKey: "paltaBrainSession")
            .map { try JSONDecoder().decode(Session.self, from: $0) }
        
        XCTAssertEqual(sessionManager.sessionId, initialSessionId)
        XCTAssertEqual(session?.id, initialSessionId)
        XCTAssertEqual(session?.lastEventTimestamp, mockedTimestamp)
    }
    
    func testConcurrentEventCounterIncrement() {
        var counters: IndexSet = []
        let syncroQueue = DispatchQueue(label: "")
        
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            for _ in 0...999 {
                let counter = sessionManager.nextEventNumber()
                
                syncroQueue.async {
                    counters.insert(counter)
                }
            }
        }
        
        syncroQueue.sync {
            // Wait syncro queue to finish
        }
        
        XCTAssertEqual(counters, IndexSet(0...9999))
    }
}
