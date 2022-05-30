//
//  UserPropertiesKeeper.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 08.04.2022.
//

import Foundation
import PaltaLibCore

protocol UserPropertiesProvider: AnyObject {
    var userId: String? { get }
    var deviceId: String? { get }
}

protocol UserPropertiesKeeper: UserPropertiesProvider {
    var userId: String? { get set }
    var deviceId: String? { get set }
}

final class UserPropertiesKeeperImpl: UserPropertiesKeeper {
    var userId: String? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return userProperties?.userId
        }
        set {
            lock.lock()
            userProperties?.userId = newValue
            lock.unlock()
        }
    }

    var deviceId: String? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return userProperties?.deviceId
        }
        set {
            lock.lock()
            userProperties?.deviceId = newValue
            lock.unlock()
        }
    }

    var useIDFAasDeviceId = false

    private lazy var userProperties: UserProperties? = userDefaults.object(for: defaultsKey) ?? UserProperties() {
        didSet {
            userDefaults.set(userProperties, for: defaultsKey)
        }
    }
    
    private let lock = NSRecursiveLock()

    private let defaultsKey = "paltaBrainUserProperties"
    private let trackingOptionsProvider: TrackingOptionsProvider
    private let deviceInfoProvider: DeviceInfoProvider
    private let userDefaults: UserDefaults

    init(
        trackingOptionsProvider: TrackingOptionsProvider,
        deviceInfoProvider: DeviceInfoProvider,
        userDefaults: UserDefaults
    ) {
        self.trackingOptionsProvider = trackingOptionsProvider
        self.deviceInfoProvider = deviceInfoProvider
        self.userDefaults = userDefaults
    }

    func generateDeviceId(forced: Bool = false) {
        lock.lock()
        defer { lock.unlock() }

        guard deviceId == nil || forced else {
            return
        }

        if
            useIDFAasDeviceId,
            trackingOptionsProvider.trackingOptions.shouldTrackIDFA(),
            let idfa = deviceInfoProvider.idfa
        {
            deviceId = idfa
        } else if
            trackingOptionsProvider.trackingOptions.shouldTrackIDFV(),
            let idfv = deviceInfoProvider.idfv
        {
            deviceId = idfv
        } else {
            deviceId = "\(UUID().uuidString)R"
        }
    }
}
