//
//  UserPropertiesKeeperTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 08.04.2022.
//

import XCTest
import Amplitude
@testable import PaltaLibAnalytics

final class UserPropertiesKeeperTests: XCTestCase {
    var uuidGeneratorMock: UUIDGeneratorMock!
    var trackerOptionsMock: TrackingOptionsProviderMock!
    var deviceInfoMock: DeviceInfoProviderMock!
    var userDefaults: UserDefaults!

    var keeper: UserPropertiesKeeperImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        uuidGeneratorMock = .init()
        trackerOptionsMock = .init()
        deviceInfoMock = .init()
        userDefaults = UserDefaults()
        
        uuidGeneratorMock.uuids = [UUID()]

        keeper = UserPropertiesKeeperImpl(
            uuidGenerator: uuidGeneratorMock,
            trackingOptionsProvider: trackerOptionsMock,
            deviceInfoProvider: deviceInfoMock,
            userDefaults: userDefaults
        )
    }

    func testProvidingCorrectIDs() {
        let guid = UUID().uuidString
        keeper.userId = "mock-user-id"
        keeper.deviceId = guid
        let instanceId = keeper.instanceId

        keeper = UserPropertiesKeeperImpl(
            uuidGenerator: uuidGeneratorMock,
            trackingOptionsProvider: trackerOptionsMock,
            deviceInfoProvider: deviceInfoMock,
            userDefaults: userDefaults
        )

        XCTAssertEqual(keeper.userId, "mock-user-id")
        XCTAssertEqual(keeper.deviceId, guid)
        XCTAssertEqual(keeper.instanceId, instanceId)
    }

    func testGenerateDeviceIdWithIDFA() {
        deviceInfoMock.idfa = "IDFA"
        deviceInfoMock.idfv = "IDFV"

        keeper.useIDFAasDeviceId = true
        keeper.generateDeviceId(forced: true)

        XCTAssertEqual(keeper.deviceId, "IDFA")
    }

    func testGenerateDeviceIdWithIDFADisabled() {
        deviceInfoMock.idfa = "IDFA"
        deviceInfoMock.idfv = "IDFV"

        keeper.generateDeviceId(forced: true)

        XCTAssertEqual(keeper.deviceId, "IDFV")
    }

    func testGenerateDeviceIdWithNoIDFA() {
        deviceInfoMock.idfa = nil
        deviceInfoMock.idfv = "IDFV"

        keeper.useIDFAasDeviceId = true
        keeper.generateDeviceId(forced: true)

        XCTAssertEqual(keeper.deviceId, "IDFV")
    }

    func testGenerateDeviceIdIgnoreIDFA() {
        deviceInfoMock.idfa = "IDFA"
        deviceInfoMock.idfv = "IDFV"
        trackerOptionsMock.trackingOptions = AMPTrackingOptions().disableIDFA()

        keeper.useIDFAasDeviceId = true
        keeper.generateDeviceId(forced: true)

        XCTAssertEqual(keeper.deviceId, "IDFV")
    }

    func testGenerateDeviceIdIgnoreIDFV() {
        deviceInfoMock.idfa = "IDFA"
        deviceInfoMock.idfv = "IDFV"
        trackerOptionsMock.trackingOptions = AMPTrackingOptions().disableIDFV()

        keeper.useIDFAasDeviceId = true
        keeper.generateDeviceId(forced: true)

        XCTAssertEqual(keeper.deviceId, "IDFA")
    }

    func testGenerateDeviceIdIgnoreIDFA_IDFV() {
        deviceInfoMock.idfa = "IDFA"
        deviceInfoMock.idfv = "IDFV"
        trackerOptionsMock.trackingOptions = AMPTrackingOptions().disableIDFV().disableIDFA()

        keeper.useIDFAasDeviceId = true
        keeper.generateDeviceId(forced: true)

        XCTAssertNotEqual(keeper.deviceId, "IDFA")
        XCTAssertNotEqual(keeper.deviceId, "IDFV")

        XCTAssertEqual(keeper.deviceId?.count, 37)
        XCTAssertEqual(keeper.deviceId?.last, "R")
    }

    func testGenerateDeviceIdNoIDFA_IDFV() {
        deviceInfoMock.idfa = nil
        deviceInfoMock.idfv = nil

        keeper.useIDFAasDeviceId = true
        keeper.generateDeviceId(forced: true)

        XCTAssertNotEqual(keeper.deviceId, "IDFA")
        XCTAssertNotEqual(keeper.deviceId, "IDFV")

        XCTAssertEqual(keeper.deviceId?.count, 37)
        XCTAssertEqual(keeper.deviceId?.last, "R")
    }

    func testSoftGenerateId() {
        keeper.generateDeviceId()

        let deviceId = keeper.deviceId

        keeper.generateDeviceId()

        XCTAssertEqual(deviceId, keeper.deviceId)
    }
    
    func testConcurrentInstanceId() {
        var idSet: Set<UUID> = []
        let lock = NSRecursiveLock()
        
        DispatchQueue.concurrentPerform(iterations: 100) { [keeper] _ in
            let id = keeper!.instanceId
            
            lock.lock()
            idSet.insert(id)
            lock.unlock()
        }
        
        XCTAssertEqual(idSet.count, 1)
    }
}
