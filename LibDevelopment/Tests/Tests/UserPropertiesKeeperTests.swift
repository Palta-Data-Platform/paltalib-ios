//
//  UserPropertiesKeeperTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 08.04.2022.
//

import XCTest
@testable import PaltaLibAnalytics

final class UserPropertiesKeeperTests: XCTestCase {
    var userDefaults: UserDefaults!
    var keeper: UserPropertiesKeeperImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        userDefaults = UserDefaults()
        keeper = UserPropertiesKeeperImpl(userDefaults: userDefaults)
    }

    func testProvidingCorrectIDs() {
        let guid = UUID()
        keeper.userId = "mock-user-id"
        keeper.deviceId = guid

        keeper = UserPropertiesKeeperImpl(userDefaults: userDefaults)

        XCTAssertEqual(keeper.userId, "mock-user-id")
        XCTAssertEqual(keeper.deviceId, guid)
    }
}
