//
//  PaltaAnalytics+Configure.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation

public extension PaltaAnalytics {
    func setAPIKey(_ apiKey: String, and baseURL: URL? = nil) {
        assembly?.analyticsCoreAssembly.configurationService.requestConfigs(apiKey: apiKey, host: baseURL) { result in
            switch result {
            case .success(let config):
                self.apply(config, apiKey: apiKey, baseURL: baseURL)
                
            case .failure:
                print("PaltaLib: Analytics: Failed to load remote config. Using default instead")
                self.apply(.default, apiKey: apiKey, baseURL: baseURL)
            }
        }
    }
    
    private func apply(_ config: RemoteConfig, apiKey: String, baseURL: URL?) {
        guard let assembly = assembly else { return }

        ConfigApplyService(
            remoteConfig: config,
            apiKey: apiKey,
            baseURL: baseURL,
            assembly: assembly
        ).apply()
    }
}
