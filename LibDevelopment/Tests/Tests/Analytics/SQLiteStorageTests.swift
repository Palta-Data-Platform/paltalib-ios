//
//  SQLiteStorageTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 26/11/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class SQLiteStorageTests: XCTestCase {
    private var url: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        url = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(UUID().uuidString)
        
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        try FileManager.default.removeItem(at: url)
    }
    
    func testInit() throws {
        _ = try SQLiteStorage(folderURL: url)
    }
    
    func testStoreAndLoad() throws {
        let originalEvents = (0...20).map {
            Event.mock(uuid: UUID(), timestamp: $0)
        }

        let storage1 = try SQLiteStorage(folderURL: url)

        originalEvents.forEach {
            storage1.storeEvent($0)
        }

        let storage2 = try SQLiteStorage(folderURL: url)

        let eventsLoaded = expectation(description: "Events loaded")

        storage2.loadEvents { events in
            let sortedEvents = events.sorted(by: { $0.timestamp < $1.timestamp })

            XCTAssertEqual(sortedEvents, originalEvents)
            eventsLoaded.fulfill()
        }

        wait(for: [eventsLoaded], timeout: 0.05)
    }

    func testRemove() throws {
        let originalEvents = (0...20).map {
            Event.mock(uuid: UUID(), timestamp: $0)
        }

        let storage1 = try SQLiteStorage(folderURL: url)

        originalEvents.forEach {
            storage1.storeEvent($0)
        }

        let removedEvent = originalEvents.randomElement()!
        storage1.removeEvent(removedEvent)

        let storage2 = try SQLiteStorage(folderURL: url)

        let eventsLoaded = expectation(description: "Events loaded")
        let expectedEvents = originalEvents.filter { $0 != removedEvent }

        storage2.loadEvents { events in
            let sortedEvents = events.sorted(by: { $0.timestamp < $1.timestamp })

            XCTAssertEqual(sortedEvents, expectedEvents)
            eventsLoaded.fulfill()
        }

        wait(for: [eventsLoaded], timeout: 0.05)
    }
}
