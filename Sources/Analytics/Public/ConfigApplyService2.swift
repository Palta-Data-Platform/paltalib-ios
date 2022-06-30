//
//  ConfigApplyService2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation

final class ConfigApplyService2 {
    private let remoteConfig: RemoteConfig
    private let apiKey: String
    private let eventQueueAssembly: EventQueue2Assembly
    
    init(remoteConfig: RemoteConfig, apiKey: String, eventQueueAssembly: EventQueue2Assembly) {
        self.remoteConfig = remoteConfig
        self.apiKey = apiKey
        self.eventQueueAssembly = eventQueueAssembly
    }
    
    func apply() {
        eventQueueAssembly.eventQueue.trackingSessionEvents = true
        eventQueueAssembly.eventQueueCore.config = .init(
            maxBatchSize: 100,
            uploadInterval: 30,
            uploadThreshold: 40,
            maxEvents: 1000
        )
        eventQueueAssembly.batchSender.url = URL(string: "")
        eventQueueAssembly.batchSender.apiToken = apiKey
    }
}
