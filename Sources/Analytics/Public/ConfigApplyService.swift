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
    private let baseURL: URL?
    private let assembly: AnalyticsAssembly
    
    init(remoteConfig: RemoteConfig, apiKey: String, baseURL: URL?, assembly: AnalyticsAssembly) {
        self.remoteConfig = remoteConfig
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.assembly = assembly
    }
    
    func apply() {
        assembly.analyticsCoreAssembly.sessionManager.maxSessionAge = remoteConfig.minTimeBetweenSessions
        
        let eventQueueAssembly = assembly.eventQueueAssembly
        eventQueueAssembly.batchSender.baseURL = baseURL
        eventQueueAssembly.batchSender.apiToken = apiKey
        
        eventQueueAssembly.eventQueueCore.apply(
            EventQueueConfig(
                maxBatchSize: remoteConfig.eventUploadMaxBatchSize,
                uploadInterval: TimeInterval(remoteConfig.eventUploadPeriod),
                uploadThreshold: remoteConfig.eventUploadThreshold,
                maxEvents: remoteConfig.eventMaxCount
            )
        )
    }
}
