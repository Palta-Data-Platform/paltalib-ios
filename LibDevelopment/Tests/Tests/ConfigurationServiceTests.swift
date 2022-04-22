//
//  ConfigurationServiceTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 21.04.2022.
//

import XCTest
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

        userDefaults.set(nil, forKey: "paltaBrainRemoteConfig")
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
                            trackingSessionEvents: false
                        ),
                        url: URL(string: "https://mock.url")
                    )
                ]
            )
        )

        let successCalled = expectation(description: "Success called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK") { result in
            guard case let .success(config) = result else {
                return
            }

            XCTAssertEqual(config.targets.first?.url, URL(string: "https://mock.url"))
            XCTAssertEqual(config.targets.first?.settings.eventMaxCount, 1228)

            successCalled.fulfill()
        }

        XCTAssertEqual(httpClientMock.request as? AnalyticsHTTPRequest, .remoteConfig("API_KEY_MCK"))

        wait(for: [successCalled], timeout: 0.01)

        XCTAssertNotNil(userDefaults.object(for: "paltaBrainRemoteConfig") as RemoteConfig?)
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
                        trackingSessionEvents: false
                    ),
                    url: URL(string: "https://mock.url")
                )
            ]
        )

        httpClientMock.result = .success(remoteConfig)

        let successCalled = expectation(description: "Success called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK") { result in
            guard case let .success(config) = result else {
                return
            }

            XCTAssertEqual(config.targets.first?.url, URL(string: "https://mock.url"))
            XCTAssertEqual(config.targets.first?.settings.eventMaxCount, 1228)

            successCalled.fulfill()
        }

        XCTAssertEqual(httpClientMock.request as? AnalyticsHTTPRequest, .remoteConfig("API_KEY_MCK"))

        wait(for: [successCalled], timeout: 0.01)

        XCTAssertEqual(userDefaults.object(for: "paltaBrainRemoteConfig"), remoteConfig)
    }

    func testRequestConfigErrorWithoutCache() {
        httpClientMock.result = .failure(NSError(domain: "some", code: 888, userInfo: nil))

        let failCalled = expectation(description: "Fail called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK") { result in
            guard case .failure = result else {
                return
            }

            failCalled.fulfill()
        }

        wait(for: [failCalled], timeout: 0.01)
    }

    func testRequestConfigErrorWithCache() {
        cacheConfig()

        httpClientMock.result = .failure(NSError(domain: "some", code: 888, userInfo: nil))

        let successCalled = expectation(description: "Success called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK") { result in
            guard case let .success(config) = result else {
                return
            }

            XCTAssertEqual(config.targets.first?.url, URL(string: "https://url.mock"))
            XCTAssertEqual(config.targets.first?.settings.minTimeBetweenSessionsMillis, 678)

            successCalled.fulfill()
        }

        wait(for: [successCalled], timeout: 0.01)
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
                        trackingSessionEvents: true
                    ),
                    url: URL(string: "https://url.mock")
                )
            ]
        )
        userDefaults.set(cachedConfig, for: "paltaBrainRemoteConfig")
    }
}
