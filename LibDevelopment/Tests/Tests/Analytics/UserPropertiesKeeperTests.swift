//
//  UserPropertiesKeeperTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 08.04.2022.
//

import XCTest
@testable import PaltaLibAnalytics

final class UserPropertiesKeeperTests: XCTestCase {
    var uuidGeneratorMock: UUIDGeneratorMock!
    var deviceInfoMock: DeviceInfoProviderMock!
    var userDefaults: UserDefaults!

    var keeper: UserPropertiesKeeperImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        uuidGeneratorMock = .init()
        deviceInfoMock = .init()
        userDefaults = UserDefaults()
        
        uuidGeneratorMock.uuids = [UUID()]

        keeper = UserPropertiesKeeperImpl(
            uuidGenerator: uuidGeneratorMock,
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
            deviceInfoProvider: deviceInfoMock,
            userDefaults: userDefaults
        )

        XCTAssertEqual(keeper.userId, "mock-user-id")
        XCTAssertEqual(keeper.deviceId, guid)
        XCTAssertEqual(keeper.instanceId, instanceId)
    }

    func testGenerateDeviceIdNoIDFA_IDFV() {
        let id = UUID()
        uuidGeneratorMock.uuids = [id]
        keeper.generateDeviceId(forced: true)
        
        XCTAssertEqual(keeper.deviceId, id.uuidString)
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
