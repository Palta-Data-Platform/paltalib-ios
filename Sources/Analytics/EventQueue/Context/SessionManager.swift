//
//  SessionManager.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import Foundation
import UIKit
import Amplitude

protocol SessionIdProvider {
    var sessionId: Int { get }
}

protocol SessionManager: AnyObject {
    var sessionEventLogger: ((String, Int) -> Void)? { get set }

    func refreshSession(with event: Event)
    func refreshSession(with event: BatchEvent)
    func start()
    func startNewSession()
}

final class SessionManagerImpl: SessionManager, SessionIdProvider {
    var sessionId: Int {
        session.id
    }

    var maxSessionAge: Int = 5 * 60 * 1000

    var sessionEventLogger: ((String, Int) -> Void)?

    private var session: Session {
        get {
            lock.lock()
            defer { lock.unlock() }
            
            if let session = _session {
                return session
            } else {
                let session = restoreSession() ?? newSession()
                _session = session
                return session
            }
        }
        
        set {
            lock.lock()
            _session = newValue
            lock.unlock()
        }
    }

    private var _session: Session? {
        didSet {
            saveSession()
        }
    }

    private var subscriptionToken: NSObjectProtocol?
    
    private let lock = NSRecursiveLock()
    private let defaultsKey = "paltaBrainSession"
    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter

    init(userDefaults: UserDefaults, notificationCenter: NotificationCenter) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter

        subscribeForNotifications()
    }

    func refreshSession(with event: Event) {
        session.lastEventTimestamp = event.timestamp
    }
    
    func refreshSession(with event: BatchEvent) {
        session.lastEventTimestamp = event.timestamp
    }

    func start() {
        onBecomeActive()
    }

    func startNewSession() {
        lock.lock()
        sessionEventLogger?(kAMPSessionEndEvent, session.lastEventTimestamp)
        session = newSession()
        lock.unlock()
    }

    func setSessionId(_ sessionId: Int) {
        lock.lock()
        session = Session(id: sessionId)
        lock.unlock()
    }

    private func subscribeForNotifications() {
        subscriptionToken = notificationCenter.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in self?.onBecomeActive()  }
        )
    }

    private func onBecomeActive() {
        lock.lock()
        session = restoreSession() ?? newSession()
        lock.unlock()
    }

    private func newSession() -> Session {
        sessionEventLogger?(kAMPSessionStartEvent, .currentTimestamp())
        return Session(id: .currentTimestamp())
    }

    private func restoreSession() -> Session? {
        guard
            let session: Session = userDefaults.object(for: defaultsKey),
            Int.currentTimestamp() - session.lastEventTimestamp < maxSessionAge
        else {
            return nil
        }

        return session
    }

    private func saveSession() {
        userDefaults.set(_session, for: defaultsKey)
    }
}
