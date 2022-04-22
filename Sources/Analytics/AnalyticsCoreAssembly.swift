//
//  AnalyticsCoreAssembly.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 11.04.2022.
//

import Foundation
import PaltaLibCore

final class AnalyticsCoreAssembly {
    private(set) lazy var trackingOptionsProvider = TrackingOptionsProviderImpl()

    private(set) lazy var userPropertiesKeeper = UserPropertiesKeeperImpl(
        trackingOptionsProvider: trackingOptionsProvider,
        deviceInfoProvider: DeviceInfoProviderImpl(),
        userDefaults: .standard
    )

    private(set) lazy var sessionManager = SessionManagerImpl(
        userDefaults: .standard,
        notificationCenter: .default
    )

    private(set) lazy var configurationService = ConfigurationService(
        userDefaults: .standard,
        httpClient: coreAssembly.httpClient
    )

    private let coreAssembly: CoreAssembly

    init(coreAssembly: CoreAssembly) {
        self.coreAssembly = coreAssembly
    }
}
