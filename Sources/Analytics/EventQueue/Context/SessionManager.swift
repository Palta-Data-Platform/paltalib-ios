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

    func refreshSession(with timestamp: Int)
    func start()
    func startNewSession()
}

final class SessionManagerImpl: SessionManager, SessionIdProvider {
    var sessionId: Int {
        session.id
    }

    var maxSessionAge: Int {
        get {
            userDefaults.object(for: "maxSessionAge") ?? 5 * 60 * 1000
        }
        set {
            userDefaults.set(newValue, for: "maxSessionAge")
        }
    }

    var sessionEventLogger: ((String, Int) -> Void)?

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
        let work = {
            guard UIApplication.shared.applicationState != .background else {
                return
            }

            self.onBecomeActive()
        }
        
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }

    func startNewSession() {
        lock.lock()
        sessionEventLogger?(kAMPSessionEndEvent, session.lastEventTimestamp)
        let timestamp = Int.currentTimestamp()
        let session = Session(id: timestamp)
        self.session = session
        sessionEventLogger?(kAMPSessionStartEvent, timestamp)
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
            let timestamp = Int.currentTimestamp()
            let session = Session(id: timestamp)
            self.session = session
            sessionEventLogger?(kAMPSessionStartEvent, timestamp)
            return session
        }
    }

    private func saveSession() {
        userDefaults.set(_session, for: defaultsKey)
    }
    
    private func isSessionValid(_ session: Session) -> Bool {
        Int.currentTimestamp() - session.lastEventTimestamp < maxSessionAge
    }
}
