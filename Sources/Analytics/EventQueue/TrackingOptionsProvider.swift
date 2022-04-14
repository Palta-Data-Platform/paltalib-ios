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
        effectiveTrackingOptions
    }

    var coppaControlEnabled = false {
        didSet {
            updateEffectiveTrackingOptions()
        }
    }

    private var appliedrackingOptions: AMPTrackingOptions = .init() {
        didSet {
            updateEffectiveTrackingOptions()
        }
    }

    private lazy var effectiveTrackingOptions = makeEffectiveTrackingOptions()

    func setTrackingOptions(_ trackingOptions: AMPTrackingOptions) {
        appliedrackingOptions = trackingOptions
    }

    private func makeEffectiveTrackingOptions() -> AMPTrackingOptions {
        if coppaControlEnabled {
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
