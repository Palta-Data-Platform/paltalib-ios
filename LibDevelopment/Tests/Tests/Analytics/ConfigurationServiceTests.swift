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

        userDefaults.set(nil, forKey: "paltaBrainRemoteConfig")
    }

    func testRequestConfigSuccessWithoutCache() {
        let host = URL(string: "http://test.something")
        httpClientMock.result = .success(
            RemoteConfig(
                eventUploadThreshold: 12,
                eventUploadMaxBatchSize: 13,
                eventMaxCount: 1228,
                eventUploadPeriod: 15,
                minTimeBetweenSessions: 16,
                url: URL(string: "https://mock.url")!
            )
        )

        let successCalled = expectation(description: "Success called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK", host: host) { result in
            guard case let .success(config) = result else {
                return
            }

            XCTAssertEqual(config.url, URL(string: "https://mock.url"))
            XCTAssertEqual(config.eventMaxCount, 1228)

            successCalled.fulfill()
        }

        XCTAssertEqual(
            httpClientMock.request as? GetConfigRequest,
            GetConfigRequest(host: host, apiKey: "API_KEY_MCK")
        )

        wait(for: [successCalled], timeout: 0.05)

        XCTAssertNotNil(userDefaults.object(for: "paltaBrainRemoteConfig") as RemoteConfig?)
    }

    func testRequestConfigSuccessWithCache() {
        cacheConfig()

        let remoteConfig = RemoteConfig(
            eventUploadThreshold: 788,
            eventUploadMaxBatchSize: 3789,
            eventMaxCount: 1228,
            eventUploadPeriod: 4429,
            minTimeBetweenSessions: 4393,
            url: URL(string: "https://mock.url")!
        )

        httpClientMock.result = .success(remoteConfig)

        let successCalled = expectation(description: "Success called")

        configurationService.requestConfigs(apiKey: "API_KEY_MCK", host: nil) { result in
            guard case let .success(config) = result else {
                return
            }

            XCTAssertEqual(config.url, URL(string: "https://mock.url"))
            XCTAssertEqual(config.eventMaxCount, 1228)

            successCalled.fulfill()
        }
        
        XCTAssertEqual(
            httpClientMock.request as? GetConfigRequest,
            GetConfigRequest(host: nil, apiKey: "API_KEY_MCK")
        )

        wait(for: [successCalled], timeout: 0.05)

        XCTAssertEqual(userDefaults.object(for: "paltaBrainRemoteConfig"), remoteConfig)
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

            XCTAssertEqual(config.url, URL(string: "https://url.mock"))
            XCTAssertEqual(config.minTimeBetweenSessions, 678)

            successCalled.fulfill()
        }

        wait(for: [successCalled], timeout: 0.05)
    }

    private func cacheConfig() {
        let cachedConfig = RemoteConfig(
            eventUploadThreshold: 656,
            eventUploadMaxBatchSize: 788,
            eventMaxCount: 434,
            eventUploadPeriod: 0,
            minTimeBetweenSessions: 678,
            url: URL(string: "https://url.mock")!
        )

        userDefaults.set(cachedConfig, for: "paltaBrainRemoteConfig")
    }
}
