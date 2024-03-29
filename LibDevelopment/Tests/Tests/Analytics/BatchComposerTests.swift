//
//  BatchComposerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation
import XCTest
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class BatchComposerTests: XCTestCase {
    private var uuidGenerator: UUIDGeneratorMock!
    private var contextProvider: ContextProviderMock!
    private var userInfoProvider: UserPropertiesKeeperMock!
    private var deviceInfoProvider: DeviceInfoProviderMock!
    
    private var composer: BatchComposerImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        uuidGenerator = .init()
        contextProvider = .init()
        userInfoProvider = .init()
        deviceInfoProvider = .init()
        
        composer = BatchComposerImpl(
            stack: .mock,
            uuidGenerator: uuidGenerator,
            contextProvider: contextProvider,
            userInfoProvider: userInfoProvider,
            deviceInfoProvider: deviceInfoProvider
        )
    }
    
    func testComposeBatch() throws {
        let events = [BatchEventMock(), BatchEventMock()]
        let batchId = UUID()
        let contextId = UUID()
        let context = try BatchContextMock(
            data: Data(repeating: .random(in: 0...120), count: .random(in: 20...30))
        )
        
        contextProvider.context = context
        deviceInfoProvider.country = "GB"
        deviceInfoProvider.timezoneOffsetSeconds = 898
        uuidGenerator.uuids = [batchId]
        
        let batch = composer.makeBatch(of: events, with: contextId) as? BatchMock
        
        XCTAssertEqual(batch?.context, context)
        XCTAssertEqual(batch?.events, events)
        XCTAssertEqual(batch?.common?.instanceId, userInfoProvider.instanceId)
        XCTAssertEqual(batch?.common?.countryCode, "GB")
        XCTAssertEqual(batch?.common?.utcOffset, 898)
        XCTAssertEqual(batch?.common?.batchId, batchId)
    }
    
    func testEventsSorted() throws {
        let events = [
            BatchEventMock(timestamp: 7),
            BatchEventMock(timestamp: 2),
            BatchEventMock(timestamp: 55),
            BatchEventMock(timestamp: 34)
        ]
        
        let contextId = UUID()
        let context = try BatchContextMock(
            data: Data(repeating: .random(in: 0...120), count: .random(in: 20...30))
        )
        
        contextProvider.context = context
        uuidGenerator.uuids = [UUID()]
        
        let batch = composer.makeBatch(of: events, with: contextId) as? BatchMock
        
        XCTAssertEqual(
            batch?.events?.map { $0.timestamp },
            [2, 7, 34, 55]
        )
    }
}
