//
//  SessionManager.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import Foundation
import UIKit
import PaltaLibAnalyticsModel

protocol SessionIdProvider {
    var sessionId: Int { get }
}

protocol SessionManager: AnyObject {
    var sessionStartLogger: ((Int) -> Void)? { get set }

    func refreshSession(with timestamp: Int)

    func start()
}

final class SessionManagerImpl: SessionManager, SessionIdProvider {
    var sessionId: Int {
        session.id
    }

    var maxSessionAge: Int {
        get {
            userDefaults.object(for: "maxSessionAge") ?? 5 * 60
        }
        set {
            userDefaults.set(newValue, for: "maxSessionAge")
        }
    }

    var sessionStartLogger: ((Int) -> Void)?

    private var session: Session {
        get {
            lock.lock()
            defer { lock.unlock() }
            
            if let session = _session {
                return session
            } else {
                return loadSession()
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

    func refreshSession(with timestamp: Int) {
        lock.lock()
        session.lastEventTimestamp = timestamp
        lock.unlock()
    }

    func start() {
        loadSession()
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
        loadSession()
    }

    @discardableResult
    private func loadSession() -> Session {
        lock.lock()
        defer { lock.unlock() }
        if
            let session: Session = userDefaults.object(for: defaultsKey),
            isSessionValid(session)
        {
            self.session = session
            return session
        } else {
            let timestamp = currentTimestamp()
            sessionStartLogger?(timestamp)
            let session = Session(id: timestamp)
            self.session = session
            return session
        }
    }

    private func saveSession() {
        userDefaults.set(_session, for: defaultsKey)
    }
    
    private func isSessionValid(_ session: Session) -> Bool {
        currentTimestamp() - session.lastEventTimestamp < (maxSessionAge * 1000)
    }
}
