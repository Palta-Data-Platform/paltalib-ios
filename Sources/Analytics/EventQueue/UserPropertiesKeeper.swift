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
            userProperties?.userId
        }
        set {
            userProperties?.userId = newValue
        }
    }

    var deviceId: String? {
        get {
            userProperties?.deviceId
        }
        set {
            userProperties?.deviceId = newValue
        }
    }

    var useIDFAasDeviceId = false

    private lazy var userProperties: UserProperties? = userDefaults.object(for: defaultsKey) ?? UserProperties() {
        didSet {
            userDefaults.set(userProperties, for: defaultsKey)
        }
    }

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
