//
//  TrackingOptionsProvider.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 14.04.2022.
//

import Foundation
import Amplitude

protocol TrackingOptionsProvider {
    var trackingOptions: AMPTrackingOptions { get }
}

final class TrackingOptionsProviderImpl: TrackingOptionsProvider {
    var trackingOptions: AMPTrackingOptions {
        lock.lock()
        defer { lock.unlock() }
        return effectiveTrackingOptions
    }
    
    var coppaControlEnabled: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _coppaControlEnabled
        }
        set {
            lock.lock()
            _coppaControlEnabled = newValue
            lock.unlock()
        }
    }

    private var _coppaControlEnabled = false {
        didSet {
            updateEffectiveTrackingOptions()
        }
    }

    private var appliedrackingOptions: AMPTrackingOptions = .init() {
        didSet {
            updateEffectiveTrackingOptions()
        }
    }

    private let lock = NSRecursiveLock()
    private lazy var effectiveTrackingOptions = makeEffectiveTrackingOptions()

    func setTrackingOptions(_ trackingOptions: AMPTrackingOptions) {
        lock.lock()
        appliedrackingOptions = trackingOptions
        lock.unlock()
    }

    private func makeEffectiveTrackingOptions() -> AMPTrackingOptions {
        if _coppaControlEnabled {
            return AMPTrackingOptions
                .copy(of: appliedrackingOptions)
                .merge(in: AMPTrackingOptions.forCoppaControl())
        } else {
            return appliedrackingOptions
        }
    }

    private func updateEffectiveTrackingOptions() {
        effectiveTrackingOptions = makeEffectiveTrackingOptions()
    }
}
