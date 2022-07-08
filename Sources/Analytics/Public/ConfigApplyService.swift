//
//  ConfigApplyService.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation

final class ConfigApplyService {
    private let remoteConfig: RemoteConfig
    private let apiKey: String
    private let assembly: AnalyticsAssembly
    
    init(remoteConfig: RemoteConfig, apiKey: String, assembly: AnalyticsAssembly) {
        self.remoteConfig = remoteConfig
        self.apiKey = apiKey
        self.assembly = assembly
    }
    
    func apply() {
        assembly.analyticsCoreAssembly.sessionManager.maxSessionAge = remoteConfig.minTimeBetweenSessions
        
        let eventQueueAssembly = assembly.eventQueueAssembly
        eventQueueAssembly.batchSender.url = remoteConfig.url
        eventQueueAssembly.batchSender.apiToken = apiKey
        
        eventQueueAssembly.eventQueueCore.config = .init(
            maxBatchSize: remoteConfig.eventUploadMaxBatchSize,
            uploadInterval: TimeInterval(remoteConfig.eventUploadPeriod),
            uploadThreshold: remoteConfig.eventUploadThreshold,
            maxEvents: remoteConfig.eventMaxCount
        )
    }
}
