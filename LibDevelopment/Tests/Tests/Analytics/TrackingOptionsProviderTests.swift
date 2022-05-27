//
//  TrackingOptionsProviderTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 14.04.2022.
//

import XCTest
import Amplitude
@testable import PaltaLibAnalytics

final class TrackingOptionsProviderTests: XCTestCase {
    func testCoppaOn1() {
        let provider = TrackingOptionsProviderImpl()

        provider.coppaControlEnabled = true

        XCTAssertTrue(provider.trackingOptions.shouldTrackCarrier())
        XCTAssertTrue(provider.trackingOptions.shouldTrackCountry())
        XCTAssertTrue(provider.trackingOptions.shouldTrackLanguage())
        XCTAssertTrue(provider.trackingOptions.shouldTrackPlatform())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackVersionName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceModel())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceManufacturer())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSVersion())

        XCTAssertFalse(provider.trackingOptions.shouldTrackCity())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIPAddress())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIDFA())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIDFV())
        XCTAssertFalse(provider.trackingOptions.shouldTrackLatLng())
    }

    func testCoppaOn2() {
        let provider = TrackingOptionsProviderImpl()

        provider.setTrackingOptions(
            AMPTrackingOptions()
                .disableIPAddress()
                .disableCity()
                .disableIDFA()
        )

        provider.coppaControlEnabled = true

        XCTAssertTrue(provider.trackingOptions.shouldTrackCarrier())
        XCTAssertTrue(provider.trackingOptions.shouldTrackCountry())
        XCTAssertTrue(provider.trackingOptions.shouldTrackLanguage())
        XCTAssertTrue(provider.trackingOptions.shouldTrackPlatform())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackVersionName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceModel())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceManufacturer())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSVersion())

        XCTAssertFalse(provider.trackingOptions.shouldTrackCity())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIPAddress())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIDFA())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIDFV())
        XCTAssertFalse(provider.trackingOptions.shouldTrackLatLng())
    }

    func testCoppaOn3() {
        let provider = TrackingOptionsProviderImpl()

        provider.coppaControlEnabled = true

        provider.setTrackingOptions(
            AMPTrackingOptions()
        )

        XCTAssertTrue(provider.trackingOptions.shouldTrackCarrier())
        XCTAssertTrue(provider.trackingOptions.shouldTrackCountry())
        XCTAssertTrue(provider.trackingOptions.shouldTrackLanguage())
        XCTAssertTrue(provider.trackingOptions.shouldTrackPlatform())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackVersionName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceModel())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceManufacturer())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSVersion())

        XCTAssertFalse(provider.trackingOptions.shouldTrackCity())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIPAddress())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIDFA())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIDFV())
        XCTAssertFalse(provider.trackingOptions.shouldTrackLatLng())
    }

    func testCoppaOff1() {
        let provider = TrackingOptionsProviderImpl()

        provider.setTrackingOptions(
            AMPTrackingOptions()
                .disableIPAddress()
                .disableCity()
                .disableIDFA()
        )

        provider.coppaControlEnabled = false

        XCTAssertTrue(provider.trackingOptions.shouldTrackCarrier())
        XCTAssertTrue(provider.trackingOptions.shouldTrackCountry())
        XCTAssertTrue(provider.trackingOptions.shouldTrackLanguage())
        XCTAssertTrue(provider.trackingOptions.shouldTrackPlatform())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackVersionName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceModel())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceManufacturer())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSVersion())

        XCTAssertFalse(provider.trackingOptions.shouldTrackCity())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIPAddress())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIDFA())
        XCTAssertTrue(provider.trackingOptions.shouldTrackIDFV())
        XCTAssertTrue(provider.trackingOptions.shouldTrackLatLng())
    }

    func testCoppaOnOff1() {
        let provider = TrackingOptionsProviderImpl()

        provider.coppaControlEnabled = true

        provider.setTrackingOptions(
            AMPTrackingOptions()
                .disableIPAddress()
                .disableCity()
                .disableIDFA()
        )

        provider.coppaControlEnabled = false

        XCTAssertTrue(provider.trackingOptions.shouldTrackCarrier())
        XCTAssertTrue(provider.trackingOptions.shouldTrackCountry())
        XCTAssertTrue(provider.trackingOptions.shouldTrackLanguage())
        XCTAssertTrue(provider.trackingOptions.shouldTrackPlatform())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackVersionName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceModel())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceManufacturer())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSVersion())

        XCTAssertFalse(provider.trackingOptions.shouldTrackCity())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIPAddress())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIDFA())
        XCTAssertTrue(provider.trackingOptions.shouldTrackIDFV())
        XCTAssertTrue(provider.trackingOptions.shouldTrackLatLng())
    }

    func testCoppaOnOff2() {
        let provider = TrackingOptionsProviderImpl()

        provider.setTrackingOptions(
            AMPTrackingOptions()
                .disableIPAddress()
                .disableCity()
                .disableIDFA()
        )

        provider.coppaControlEnabled = true
        provider.coppaControlEnabled = false

        XCTAssertTrue(provider.trackingOptions.shouldTrackCarrier())
        XCTAssertTrue(provider.trackingOptions.shouldTrackCountry())
        XCTAssertTrue(provider.trackingOptions.shouldTrackLanguage())
        XCTAssertTrue(provider.trackingOptions.shouldTrackPlatform())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackVersionName())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceModel())
        XCTAssertTrue(provider.trackingOptions.shouldTrackDeviceManufacturer())
        XCTAssertTrue(provider.trackingOptions.shouldTrackOSVersion())

        XCTAssertFalse(provider.trackingOptions.shouldTrackCity())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIPAddress())
        XCTAssertFalse(provider.trackingOptions.shouldTrackIDFA())
        XCTAssertTrue(provider.trackingOptions.shouldTrackIDFV())
        XCTAssertTrue(provider.trackingOptions.shouldTrackLatLng())
    }
}
