//
//  ConfigurationServiceTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 21.04.2022.
//

import XCTest
import PaltaLibCore
@testable import PaltaLibAnalytics

final class ConfigurationServiceTests: XCTestCase {
    var userDefaults: UserDefaults!
    var httpClientMock: HTTPClientMock!
    var configurationService: ConfigurationService!

    override func setUpWithError() throws {
        try super.setUpWithError()

        userDefaults = .init()
        httpClientMock = .init()
        configurationService = .init(userDefaults: userDefaults, httpClient: httpClientMock)

        userDefaults.set(nil, forKey: "paltaBrainRemoteConfig_legacy")
    }

    func testRequestConfigSuccessWithoutCache() {
        httpClientMock.result = .success(
            RemoteConfig(
                targets: [
                    ConfigTarget(
                        name: .paltabrain,
                        settings: ConfigSettings(
                            eventUploadThreshold: 788,
                            eventUploadMaxBatchSize: 3789,
                            eventMaxCount: 1228,
                            eventUploadPeriodSeconds: 4429,
                            minTimeBetweenSessionsMillis: 4393,
                            trackingSessionEvents: false,
                            realtimeEventTypes: [],
                                        excludedEventTypes: [],
                            sendMechanism: .paltaBrain
                        )
                    )
                ]
            )
        )

        let successCalled = expectation(description: "Success called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK", host: URL(string: "https://test.test")) { result in
            guard case let .success(config) = result else {
                return
            }

            XCTAssertEqual(config.targets.first?.settings.eventMaxCount, 1228)

            successCalled.fulfill()
        }
        
        XCTAssertEqual(
            httpClientMock.request as? AnalyticsHTTPRequest,
            .remoteConfig(URL(string: "https://test.test"), "API_KEY_MCK")
        )

        wait(for: [successCalled], timeout: 0.05)

        XCTAssertNotNil(userDefaults.object(for: "paltaBrainRemoteConfig_legacy") as RemoteConfig?)
    }

    func testRequestConfigSuccessWithCache() {
        cacheConfig()

        let remoteConfig = RemoteConfig(
            targets: [
                ConfigTarget(
                    name: .paltabrain,
                    settings: ConfigSettings(
                        eventUploadThreshold: 788,
                        eventUploadMaxBatchSize: 3789,
                        eventMaxCount: 1228,
                        eventUploadPeriodSeconds: 4429,
                        minTimeBetweenSessionsMillis: 4393,
                        trackingSessionEvents: false,
                        realtimeEventTypes: [],
                        excludedEventTypes: [],
                        sendMechanism: .paltaBrain
                    )
                )
            ]
        )

        httpClientMock.result = .success(remoteConfig)

        let successCalled = expectation(description: "Success called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK", host: nil) { result in
            guard case let .success(config) = result else {
                return
            }
            
            XCTAssertEqual(config.targets.first?.settings.eventMaxCount, 1228)

            successCalled.fulfill()
        }

        XCTAssertEqual(httpClientMock.request as? AnalyticsHTTPRequest, .remoteConfig(nil, "API_KEY_MCK"))

        wait(for: [successCalled], timeout: 0.05)

        XCTAssertEqual(userDefaults.object(for: "paltaBrainRemoteConfig_legacy"), remoteConfig)
    }

    func testRequestConfigErrorWithoutCache() {
        httpClientMock.result = .failure(NetworkErrorWithoutResponse.urlError(URLError(.timedOut)))

        let failCalled = expectation(description: "Fail called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK", host: nil) { result in
            guard case .failure = result else {
                return
            }

            failCalled.fulfill()
        }

        wait(for: [failCalled], timeout: 0.05)
    }

    func testRequestConfigErrorWithCache() {
        cacheConfig()

        httpClientMock.result = .failure(NetworkErrorWithoutResponse.noData)

        let successCalled = expectation(description: "Success called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK", host: nil) { result in
            guard case let .success(config) = result else {
                return
            }

            XCTAssertEqual(config.targets.first?.settings.minTimeBetweenSessionsMillis, 678)

            successCalled.fulfill()
        }

        wait(for: [successCalled], timeout: 0.05)
    }

    private func cacheConfig() {
        let cachedConfig = RemoteConfig(
            targets: [
                ConfigTarget(
                    name: .paltabrain,
                    settings: ConfigSettings(
                        eventUploadThreshold: 656,
                        eventUploadMaxBatchSize: 788,
                        eventMaxCount: 434,
                        eventUploadPeriodSeconds: 0,
                        minTimeBetweenSessionsMillis: 678,
                        trackingSessionEvents: true,
                        realtimeEventTypes: [],
                        excludedEventTypes: [],
                        sendMechanism: .paltaBrain
                    )
                )
            ]
        )
        userDefaults.set(cachedConfig, for: "paltaBrainRemoteConfig_legacy")
    }
}
