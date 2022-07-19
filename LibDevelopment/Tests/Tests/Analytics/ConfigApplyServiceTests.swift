//
//  ConfigApplyServiceTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 18/05/2022.
//

import Foundation
import XCTest
import Amplitude
@testable import PaltaLibAnalytics

final class ConfigApplyServiceTests: XCTestCase {
    private let assemblyProvider = EventQueueAssemblyProviderMock()
    
    private var defaultAmplitudeInstance: Amplitude?
    private var defaultPaltaInstance: EventQueueAssembly?
    
    private var paltaQueueAssemblies: [EventQueueAssembly] = []
    private var amplitudeInstances: [Amplitude] = []
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        defaultPaltaInstance = nil
        defaultAmplitudeInstance = nil
        
        paltaQueueAssemblies = []
        amplitudeInstances = []
    }
    
    func testTwoTargetsDefault() {
        let config = RemoteConfig.default
        
        let amplitude = Amplitude()
        let palta = assemblyProvider.newEventQueueAssembly()
        
        let coreConfigApplied = expectation(description: "Core config applied")
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider
        )
        
        service.apply(
            defaultPaltaAssembly: &defaultPaltaInstance,
            defaultAmplitude: &defaultAmplitudeInstance,
            paltaAssemblies: &paltaQueueAssemblies,
            amplitudeInstances: &amplitudeInstances
        )
        
        palta.eventQueueCore.addBarrier(coreConfigApplied.fulfill)
        wait(for: [coreConfigApplied], timeout: 0.1)
        
        XCTAssertNil(defaultAmplitudeInstance)
        XCTAssertNil(defaultPaltaInstance)
        
        XCTAssertEqual(paltaQueueAssemblies.count, 1)
        XCTAssertEqual(amplitudeInstances.count, 1)
        
        XCTAssertNotNil(paltaQueueAssemblies.first?.eventQueueCore.config)
        
        XCTAssert(paltaQueueAssemblies.first === palta)
        XCTAssert(amplitudeInstances.first === amplitude)
        
        XCTAssertEqual(paltaQueueAssemblies.first?.eventSender.apiToken, "palta-key")
        XCTAssertEqual(amplitudeInstances.first?.apiKey, "amplitude-key")
    }
    
    func testOnlyAmplitude() {
        let config = RemoteConfig(targets: [.defaultAmplitude])
        
        let amplitude = Amplitude()
        let palta = assemblyProvider.newEventQueueAssembly()
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider
        )
        
        service.apply(
            defaultPaltaAssembly: &defaultPaltaInstance,
            defaultAmplitude: &defaultAmplitudeInstance,
            paltaAssemblies: &paltaQueueAssemblies,
            amplitudeInstances: &amplitudeInstances
        )
        
        XCTAssertNil(defaultAmplitudeInstance)
        XCTAssertNil(defaultPaltaInstance)
        
        XCTAssert(paltaQueueAssemblies.isEmpty)
        XCTAssertEqual(amplitudeInstances.count, 1)

        XCTAssert(amplitudeInstances.first === amplitude)
        
        XCTAssertEqual(amplitudeInstances.first?.apiKey, "amplitude-key")
    }
    
    func testOnlyPaltaBrain() {
        let config = RemoteConfig(targets: [.defaultPaltaBrain])
        
        let amplitude = Amplitude()
        let palta = assemblyProvider.newEventQueueAssembly()
        
        let coreConfigApplied = expectation(description: "Core config applied")
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider
        )
        
        service.apply(
            defaultPaltaAssembly: &defaultPaltaInstance,
            defaultAmplitude: &defaultAmplitudeInstance,
            paltaAssemblies: &paltaQueueAssemblies,
            amplitudeInstances: &amplitudeInstances
        )
        
        palta.eventQueueCore.addBarrier(coreConfigApplied.fulfill)
        wait(for: [coreConfigApplied], timeout: 0.1)
        
        XCTAssertNil(defaultAmplitudeInstance)
        XCTAssertNil(defaultPaltaInstance)
        
        XCTAssertEqual(paltaQueueAssemblies.count, 1)
        XCTAssert(amplitudeInstances.isEmpty)
        
        XCTAssertNotNil(paltaQueueAssemblies.first?.eventQueueCore.config)
        
        XCTAssert(paltaQueueAssemblies.first === palta)
        
        XCTAssertEqual(paltaQueueAssemblies.first?.eventSender.apiToken, "palta-key")
    }
    
    func testPaltaBrainOnLegacy() {
        let config = RemoteConfig(targets: [
            ConfigTarget(
                name: .paltabrain,
                settings: .init(
                    eventUploadThreshold: 1,
                    eventUploadMaxBatchSize: 1,
                    eventMaxCount: 1,
                    eventUploadPeriodSeconds: 1,
                    minTimeBetweenSessionsMillis: 1,
                    trackingSessionEvents: true,
                    realtimeEventTypes: [],
                    excludedEventTypes: [],
                    sendMechanism: .amplitude
                ),
                url: nil
            ),
            .defaultAmplitude
        ])
        
        let amplitude = Amplitude()
        let palta = assemblyProvider.newEventQueueAssembly()
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider
        )
        
        service.apply(
            defaultPaltaAssembly: &defaultPaltaInstance,
            defaultAmplitude: &defaultAmplitudeInstance,
            paltaAssemblies: &paltaQueueAssemblies,
            amplitudeInstances: &amplitudeInstances
        )
        
        XCTAssertNil(defaultAmplitudeInstance)
        XCTAssertNil(defaultPaltaInstance)
        
        XCTAssert(paltaQueueAssemblies.isEmpty)
        XCTAssertEqual(amplitudeInstances.count, 2)
        
        XCTAssert(amplitudeInstances.last === amplitude)
        
        XCTAssertEqual(amplitudeInstances.first?.apiKey, "palta-key")
        XCTAssertEqual(amplitudeInstances.last?.apiKey, "amplitude-key")
    }
    
    func testTwoPaltaBrain() {
        let config = RemoteConfig(targets: [
            ConfigTarget(
                name: .paltabrain,
                settings: .init(
                    eventUploadThreshold: 1,
                    eventUploadMaxBatchSize: 1,
                    eventMaxCount: 1,
                    eventUploadPeriodSeconds: 1,
                    minTimeBetweenSessionsMillis: 1,
                    trackingSessionEvents: true,
                    realtimeEventTypes: [],
                    excludedEventTypes: [],
                    sendMechanism: .paltaBrain
                ),
                url: URL(string: "http://example.com")
            ),
            .defaultPaltaBrain,
            .defaultAmplitude
        ])
        
        let amplitude = Amplitude()
        let palta = assemblyProvider.newEventQueueAssembly()
        
        let coreConfigApplied = expectation(description: "Core config applied")
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider
        )
        
        service.apply(
            defaultPaltaAssembly: &defaultPaltaInstance,
            defaultAmplitude: &defaultAmplitudeInstance,
            paltaAssemblies: &paltaQueueAssemblies,
            amplitudeInstances: &amplitudeInstances
        )
        
        palta.eventQueueCore.addBarrier(coreConfigApplied.fulfill)
        wait(for: [coreConfigApplied], timeout: 0.1)
        
        XCTAssertNil(defaultAmplitudeInstance)
        XCTAssertNil(defaultPaltaInstance)
        
        XCTAssertEqual(paltaQueueAssemblies.count, 2)
        XCTAssertEqual(amplitudeInstances.count, 1)
        
        XCTAssert(paltaQueueAssemblies.first === palta)
        XCTAssert(amplitudeInstances.first === amplitude)
        
        XCTAssertEqual(paltaQueueAssemblies[0].eventSender.apiToken, "palta-key")
        XCTAssertEqual(paltaQueueAssemblies.last?.eventSender.apiToken, "palta-key")
        XCTAssertEqual(amplitudeInstances.last?.apiKey, "amplitude-key")
    }
}
