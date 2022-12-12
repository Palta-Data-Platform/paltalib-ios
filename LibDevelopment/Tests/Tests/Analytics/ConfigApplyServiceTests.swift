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
    
    func testTwoTargetsDefault() throws {
        let config = RemoteConfig.default
        
        let amplitude = Amplitude()
        let palta = try assemblyProvider.newEventQueueAssembly()
        
        let coreConfigApplied = expectation(description: "Core config applied")
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider,
            host: nil
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
        
        XCTAssertEqual(paltaQueueAssemblies.first?.batchSender.apiToken, "palta-key")
        XCTAssertEqual(amplitudeInstances.first?.apiKey, "amplitude-key")
    }
    
    func testOnlyAmplitude() throws {
        let config = RemoteConfig(targets: [.defaultAmplitude])
        
        let amplitude = Amplitude()
        let palta = try assemblyProvider.newEventQueueAssembly()
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider,
            host: nil
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
    
    func testOnlyPaltaBrain() throws {
        let config = RemoteConfig(targets: [.defaultPaltaBrain])
        
        let amplitude = Amplitude()
        let palta = try assemblyProvider.newEventQueueAssembly()
        
        let coreConfigApplied = expectation(description: "Core config applied")
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider,
            host: nil
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
        
        XCTAssertEqual(paltaQueueAssemblies.first?.batchSender.apiToken, "palta-key")
    }
    
    func testPaltaBrainOnLegacy() throws {
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
                )
            ),
            .defaultAmplitude
        ])
        
        let amplitude = Amplitude()
        let palta = try assemblyProvider.newEventQueueAssembly()
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider,
            host: nil
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
    
    func testTwoPaltaBrain() throws {
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
                )
            ),
            .defaultPaltaBrain,
            .defaultAmplitude
        ])
        
        let amplitude = Amplitude()
        let palta = try assemblyProvider.newEventQueueAssembly()
        
        let coreConfigApplied = expectation(description: "Core config applied")
        
        defaultAmplitudeInstance = amplitude
        defaultPaltaInstance = palta
        
        let service = ConfigApplyService(
            remoteConfig: config,
            apiKey: "palta-key",
            amplitudeApiKey: "amplitude-key",
            eventQueueAssemblyProvider: assemblyProvider,
            host: URL(string: "http://example.com")
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
        
        XCTAssertEqual(paltaQueueAssemblies[0].batchSender.apiToken, "palta-key")
        XCTAssertEqual(paltaQueueAssemblies.last?.batchSender.apiToken, "palta-key")
        XCTAssertEqual(amplitudeInstances.last?.apiKey, "amplitude-key")
    }
}
