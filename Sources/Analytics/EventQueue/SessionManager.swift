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
    func start()
    func startNewSession()
}

final class SessionManagerImpl: SessionManager, SessionIdProvider {
    var sessionId: Int {
        session.id
    }

    var maxSessionAge: Int = 5 * 60 * 1000

    var sessionEventLogger: ((String, Int) -> Void)?

    private lazy var session: Session = restoreSession() ?? newSession() {
        didSet {
            saveSession()
        }
    }

    private var subscriptionToken: NSObjectProtocol?

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

    func start() {
        onBecomeActive()
    }

    func startNewSession() {
        sessionEventLogger?(kAMPSessionEndEvent, session.lastEventTimestamp)
        session = newSession()
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
        session = restoreSession() ?? newSession()
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
        userDefaults.set(session, for: defaultsKey)
    }
}
