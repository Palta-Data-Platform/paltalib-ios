//
//  EventComposerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import XCTest
import Amplitude
import PaltaLibCore
@testable import PaltaLibAnalytics

final class EventComposerTests: XCTestCase {
    var sessionManagerMock: SessionManagerMock!
    var userPropertiesMock: UserPropertiesKeeperMock!
    var deviceInfoProviderMock: DeviceInfoProviderMock!
    var trackingOptionsProviderMock: TrackingOptionsProviderMock!

    var composer: EventComposerImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        sessionManagerMock = SessionManagerMock()
        userPropertiesMock = UserPropertiesKeeperMock()
        deviceInfoProviderMock = DeviceInfoProviderMock()
        trackingOptionsProviderMock = TrackingOptionsProviderMock()

        composer = EventComposerImpl(
            sessionIdProvider: sessionManagerMock,
            userPropertiesProvider: userPropertiesMock,
            deviceInfoProvider: deviceInfoProviderMock,
            trackingOptionsProvider: trackingOptionsProviderMock
        )
    }

    func testCompose() {
        sessionManagerMock.sessionId = 845
        userPropertiesMock.userId = "sample-user-id"
        userPropertiesMock.deviceId = UUID().uuidString

        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: ["prop": "A"],
            apiProperties: ["api": "B"],
            groups: ["group": "C"],
            userProperties: ["user": "D"],
            groupProperties: ["groupP": "E"],
            timestamp: 11,
            outOfSession: false
        )

        XCTAssertEqual(event.eventType, "someType")
        XCTAssertEqual(event.eventProperties, ["prop": "A"])
        XCTAssertEqual(event.apiProperties, ["api": "B"])
        XCTAssertEqual(event.groups, ["group": "C"])
        XCTAssertEqual(event.userProperties, ["user": "D"])
        XCTAssertEqual(event.groupProperties, ["groupP": "E"])
        XCTAssertEqual(event.timestamp, 11)
        XCTAssertEqual(event.sessionId, 845)
        XCTAssertEqual(event.userId, "sample-user-id")
        XCTAssertEqual(event.deviceId, userPropertiesMock.deviceId)
        XCTAssertEqual(event.platform, "iOS")
        XCTAssertEqual(event.osName, "ios")
        XCTAssertEqual(event.deviceManufacturer, "Apple")
        XCTAssertEqual(event.appVersion, "X.V.C")
        XCTAssertEqual(event.osVersion, "undefinedVersion")
        XCTAssertEqual(event.deviceModel, "undefinedModel")
        XCTAssertEqual(event.carrier, "undefinedCarrier")
        XCTAssertEqual(event.language, "Sakovian")
        XCTAssertEqual(event.country, "Sakovia")
    }

    func testDefaultTimestamp() {
        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssert(abs(event.timestamp - .currentTimestamp()) < 2)
    }

    func testPositiveTimezone() {
        deviceInfoProviderMock.timezoneOffset = 1

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertEqual(event.timezone, "GMT+1")
    }

    func testNegativeTimezone() {
        deviceInfoProviderMock.timezoneOffset = -6

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertEqual(event.timezone, "GMT-6")
    }

    func testGreenwichTimezone() {
        deviceInfoProviderMock.timezoneOffset = 0

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertEqual(event.timezone, "GMT+0")
    }

    func testTwoDigitTimezone() {
        deviceInfoProviderMock.timezoneOffset = -11

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertEqual(event.timezone, "GMT-11")
    }

    func testDisablePlatformTracking() {
        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        trackingOptionsProviderMock.trackingOptions = AMPTrackingOptions().disablePlatform()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertNotNil(event.timezone)
        XCTAssertNotNil(event.country)
        XCTAssertNotNil(event.language)
        XCTAssertNotNil(event.osName)
        XCTAssertNotNil(event.osVersion)
        XCTAssertNil(event.platform)
        XCTAssertNotNil(event.appVersion)
        XCTAssertNotNil(event.deviceModel)
        XCTAssertNotNil(event.deviceManufacturer)
        XCTAssertNotNil(event.carrier)
    }

    func testDisableCountryTracking() {
        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        trackingOptionsProviderMock.trackingOptions = AMPTrackingOptions().disableCountry()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertNotNil(event.timezone)
        XCTAssertNil(event.country)
        XCTAssertNotNil(event.language)
        XCTAssertNotNil(event.osName)
        XCTAssertNotNil(event.osVersion)
        XCTAssertNotNil(event.platform)
        XCTAssertNotNil(event.appVersion)
        XCTAssertNotNil(event.deviceModel)
        XCTAssertNotNil(event.deviceManufacturer)
        XCTAssertNotNil(event.carrier)
    }

    func testDisableLanguageTracking() {
        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        trackingOptionsProviderMock.trackingOptions = AMPTrackingOptions().disableLanguage()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertNotNil(event.timezone)
        XCTAssertNotNil(event.country)
        XCTAssertNil(event.language)
        XCTAssertNotNil(event.osName)
        XCTAssertNotNil(event.osVersion)
        XCTAssertNotNil(event.platform)
        XCTAssertNotNil(event.appVersion)
        XCTAssertNotNil(event.deviceModel)
        XCTAssertNotNil(event.deviceManufacturer)
        XCTAssertNotNil(event.carrier)
    }

    func testDisableOsNameTracking() {
        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        trackingOptionsProviderMock.trackingOptions = AMPTrackingOptions().disableOSName()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertNotNil(event.timezone)
        XCTAssertNotNil(event.country)
        XCTAssertNotNil(event.language)
        XCTAssertNil(event.osName)
        XCTAssertNotNil(event.osVersion)
        XCTAssertNotNil(event.platform)
        XCTAssertNotNil(event.appVersion)
        XCTAssertNotNil(event.deviceModel)
        XCTAssertNotNil(event.deviceManufacturer)
        XCTAssertNotNil(event.carrier)
    }

    func testDisableOsVersionTracking() {
        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        trackingOptionsProviderMock.trackingOptions = AMPTrackingOptions().disableOSVersion()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertNotNil(event.timezone)
        XCTAssertNotNil(event.country)
        XCTAssertNotNil(event.language)
        XCTAssertNotNil(event.osName)
        XCTAssertNil(event.osVersion)
        XCTAssertNotNil(event.platform)
        XCTAssertNotNil(event.appVersion)
        XCTAssertNotNil(event.deviceModel)
        XCTAssertNotNil(event.deviceManufacturer)
        XCTAssertNotNil(event.carrier)
    }

    func testDisableAppVersionTracking() {
        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        trackingOptionsProviderMock.trackingOptions = AMPTrackingOptions().disableVersionName()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertNotNil(event.timezone)
        XCTAssertNotNil(event.country)
        XCTAssertNotNil(event.language)
        XCTAssertNotNil(event.osName)
        XCTAssertNotNil(event.osVersion)
        XCTAssertNotNil(event.platform)
        XCTAssertNil(event.appVersion)
        XCTAssertNotNil(event.deviceModel)
        XCTAssertNotNil(event.deviceManufacturer)
        XCTAssertNotNil(event.carrier)
    }

    func testDisableDeviceModelTracking() {
        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        trackingOptionsProviderMock.trackingOptions = AMPTrackingOptions().disableDeviceModel()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertNotNil(event.timezone)
        XCTAssertNotNil(event.country)
        XCTAssertNotNil(event.language)
        XCTAssertNotNil(event.osName)
        XCTAssertNotNil(event.osVersion)
        XCTAssertNotNil(event.platform)
        XCTAssertNotNil(event.appVersion)
        XCTAssertNil(event.deviceModel)
        XCTAssertNotNil(event.deviceManufacturer)
        XCTAssertNotNil(event.carrier)
    }

    func testDisableDeviceManufacturerTracking() {
        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        trackingOptionsProviderMock.trackingOptions = AMPTrackingOptions().disableDeviceManufacturer()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertNotNil(event.timezone)
        XCTAssertNotNil(event.country)
        XCTAssertNotNil(event.language)
        XCTAssertNotNil(event.osName)
        XCTAssertNotNil(event.osVersion)
        XCTAssertNotNil(event.platform)
        XCTAssertNotNil(event.appVersion)
        XCTAssertNotNil(event.deviceModel)
        XCTAssertNil(event.deviceManufacturer)
        XCTAssertNotNil(event.carrier)
    }

    func testDisableCarrierTracking() {
        deviceInfoProviderMock.appVersion = "X.V.C"
        deviceInfoProviderMock.language = "Sakovian"
        deviceInfoProviderMock.country = "Sakovia"

        trackingOptionsProviderMock.trackingOptions = AMPTrackingOptions().disableCarrier()

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )

        XCTAssertNotNil(event.timezone)
        XCTAssertNotNil(event.country)
        XCTAssertNotNil(event.language)
        XCTAssertNotNil(event.osName)
        XCTAssertNotNil(event.osVersion)
        XCTAssertNotNil(event.platform)
        XCTAssertNotNil(event.appVersion)
        XCTAssertNotNil(event.deviceModel)
        XCTAssertNotNil(event.deviceManufacturer)
        XCTAssertNil(event.carrier)
    }

    func testOutOfSession() {
        sessionManagerMock.sessionId = 89

        let event = composer.composeEvent(
            eventType: "someType",
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: true
        )

        XCTAssertEqual(event.sessionId, -1)
    }
}
