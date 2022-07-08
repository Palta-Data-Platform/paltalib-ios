//
//  AnalyticsCoreAssembly.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 11.04.2022.
//

import Foundation
import PaltaLibCore

final class AnalyticsCoreAssembly {
    let sdkInfoProvider: SDKInfoProvider = SDKInfoProviderImpl()
    let userPropertiesKeeper: UserPropertiesKeeperImpl
    let sessionManager: SessionManagerImpl
    let configurationService: ConfigurationService
    
    init(coreAssembly: CoreAssembly) {
        let userPropertiesKeeper = UserPropertiesKeeperImpl(
            uuidGenerator: UUIDGeneratorImpl(),
            deviceInfoProvider: DeviceInfoProviderImpl(),
            userDefaults: .standard
        )
        userPropertiesKeeper.generateDeviceId()

        let sessionManager = SessionManagerImpl(
            userDefaults: .standard,
            notificationCenter: .default
        )

        let configurationService = ConfigurationService(
            userDefaults: .standard,
            httpClient: coreAssembly.httpClient
        )
        
        self.userPropertiesKeeper = userPropertiesKeeper
        self.sessionManager = sessionManager
        self.configurationService = configurationService
        
        coreAssembly.httpClient.mandatoryHeaders["X-SDK-Name"] = sdkInfoProvider.sdkName
        coreAssembly.httpClient.mandatoryHeaders["X-SDK-Version"] = sdkInfoProvider.sdkVersion
    }
}
