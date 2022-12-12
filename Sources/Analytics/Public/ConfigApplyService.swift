//
//  ConfigApplyService.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 18/05/2022.
//

import Foundation
import Amplitude

final class ConfigApplyService {
    private let remoteConfig: RemoteConfig
    private let apiKey: String?
    private let amplitudeApiKey: String?
    private let host: URL?
    private let eventQueueAssemblyProvider: EventQueueAssemblyProvider
    
    init(
        remoteConfig: RemoteConfig,
        apiKey: String?,
        amplitudeApiKey: String?,
        eventQueueAssemblyProvider: EventQueueAssemblyProvider,
        host: URL?
    ) {
        self.remoteConfig = remoteConfig
        self.apiKey = apiKey
        self.amplitudeApiKey = amplitudeApiKey
        self.host = host
        self.eventQueueAssemblyProvider = eventQueueAssemblyProvider
    }
    
    func apply(
        defaultPaltaAssembly: inout EventQueueAssembly?,
        defaultAmplitude: inout Amplitude?,
        paltaAssemblies: inout [EventQueueAssembly],
        amplitudeInstances: inout [Amplitude]
    ) {
        remoteConfig.targets.forEach {
            apply(
                $0,
                defaultPaltaAssembly: &defaultPaltaAssembly,
                defaultAmplitude: &defaultAmplitude,
                paltaAssemblies: &paltaAssemblies,
                amplitudeInstances: &amplitudeInstances
            )
        }
        
        defaultAmplitude = nil
        defaultPaltaAssembly = nil
    }
    
    private func apply(
        _ target: ConfigTarget,
        defaultPaltaAssembly: inout EventQueueAssembly?,
        defaultAmplitude: inout Amplitude?,
        paltaAssemblies: inout [EventQueueAssembly],
        amplitudeInstances: inout [Amplitude]
    ) {
        switch (target.name, target.settings.sendMechanism, apiKey, amplitudeApiKey) {
        case
            (.amplitude, .amplitude, _, let amplitudeApiKey?),
            (.amplitude, nil, _, let amplitudeApiKey?):
            addAmplitudeTarget(
                target,
                apiKey: amplitudeApiKey,
                defaultAmplitude: &defaultAmplitude,
                amplitudeInstances: &amplitudeInstances,
                host: nil
            )
            
        case (.amplitude, .amplitude, _, nil), (.amplitude, nil, _, nil):
            print("PaltaAnalytics: error: API key for amplitude is not set")
            
        case (.amplitude, .paltaBrain, _, _):
            print("PaltaAnalytics: error: Can't use palta brain mechanism for Amplitude")
            
        case (.paltabrain, .amplitude, let apiKey?, _):
            var dummyAmplitude: Amplitude?
            addAmplitudeTarget(
                target,
                apiKey: apiKey,
                defaultAmplitude: &dummyAmplitude,
                amplitudeInstances: &amplitudeInstances,
                host: (host ?? URL(string: "https://api.paltabrain.com"))?.appendingPathComponent("/v1/amplitude")
            )
            
        case
            (.paltabrain, .paltaBrain, let apiKey?, _),
            (.paltabrain, nil, let apiKey?, _):
            addPaltaBrainTarget(
                target,
                apiKey: apiKey,
                defaultPaltaAssembly: &defaultPaltaAssembly,
                paltaAssemblies: &paltaAssemblies
            )
            
        case (.paltabrain, _, nil, _):
            print("PaltaAnalytics: error: API key for palta brain is not set")
            
        default:
            print("PaltaAnalytics: error: unconfigurable target")
        }
    }
    
    private func addAmplitudeTarget(
        _ target: ConfigTarget,
        apiKey: String,
        defaultAmplitude: inout Amplitude?,
        amplitudeInstances: inout [Amplitude],
        host: URL?
    ) {
        let amplitudeInstance: Amplitude
        
        if let defAmplitude = defaultAmplitude {
            amplitudeInstance = defAmplitude
            defaultAmplitude = nil
        } else {
            amplitudeInstance = Amplitude.instance(withName: target.name.rawValue)
        }
        
        amplitudeInstance.initializeApiKey(apiKey)
        amplitudeInstance.apply(target, host: host)
        
        amplitudeInstance.setOffline(false)

        amplitudeInstances.append(amplitudeInstance)
    }
    
    private func addPaltaBrainTarget(
        _ target: ConfigTarget,
        apiKey: String,
        defaultPaltaAssembly: inout EventQueueAssembly?,
        paltaAssemblies: inout [EventQueueAssembly]
    ) {
        let eventQueueAssembly: EventQueueAssembly
        
        if let defPaltaAssembly = defaultPaltaAssembly {
            eventQueueAssembly = defPaltaAssembly
            defaultPaltaAssembly = nil
        } else {
            do {
                eventQueueAssembly = try eventQueueAssemblyProvider.newEventQueueAssembly()
            } catch {
                print("PaltaLib: Analytics: failed to setup instance due to error: \(error)")
                return
            }
        }
        
        eventQueueAssembly.batchSender.apiToken = apiKey
        eventQueueAssembly.apply(target, host: host)
        eventQueueAssembly.batchSendController.configurationFinished()
        
        paltaAssemblies.append(eventQueueAssembly)
    }
}
