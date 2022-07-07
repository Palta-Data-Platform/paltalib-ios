//
//  PaltaAnalytics+Configure.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation

public extension PaltaAnalytics {
    func setAPIKey(_ apiKey: String) {
        assembly.analyticsCoreAssembly.configurationService.requestConfigs(apiKey: apiKey) { result in
            switch result {
            case .success(let config):
                self.apply(config, apiKey: apiKey)
                
            case .failure(let error):
                print("PaltaLib: Analytics: Failed to load remote config. Using default instead")
                self.apply(.default, apiKey: apiKey)
            }
        }
    }
    
    private func apply(_ config: RemoteConfig, apiKey: String) {
        ConfigApplyService(
            remoteConfig: config,
            apiKey: apiKey,
            eventQueueAssembly: assembly.eventQueueAssembly
        ).apply()
    }
}
