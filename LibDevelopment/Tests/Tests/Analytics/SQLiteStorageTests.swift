//
//  SQLiteStorageTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 19/12/2022.
//

import Foundation
import XCTest
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class SQLiteStorageTests: XCTestCase {
    private var stackMock: Stack!
    private var fileManager: FileManager!
    private var testURL: URL!
    
    private var storage: SQLiteStorage!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        stackMock = .mock
        
        fileManager = FileManager()
        testURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        try fileManager.createDirectory(at: testURL, withIntermediateDirectories: true)
        
        try reinitStorage()
    }
    
    override func tearDown() async throws {
        try fileManager.removeItem(at: testURL)
    }
    
    func testSaveEvent() throws {
        let event = StorableEvent(
            event: IdentifiableEvent(id: .init(), event: BatchEventMock()),
            contextId: .init()
        )
        
        storage.storeEvent(event)
        
        try reinitStorage()
        var restoredEvent: StorableEvent?
        let loadFinished = expectation(description: "Load finished")
        
        storage.loadEvents {
            restoredEvent = $0.first
            loadFinished.fulfill()
        }
        
        wait(for: [loadFinished], timeout: 0.1)
        
        XCTAssertEqual(restoredEvent?.contextId, event.contextId)
        XCTAssertEqual(restoredEvent?.event.id, event.event.id)
        XCTAssertEqual(restoredEvent?.event.event.timestamp, event.event.event.timestamp)
    }
    
    func testSaveEventError() throws {
        let event = StorableEvent(
            event: IdentifiableEvent(id: .init(), event: BatchEventMock(shouldFailSerialize: true)),
            contextId: .init()
        )
        
        storage.storeEvent(event)
        
        try reinitStorage()
        var restoredEvent: StorableEvent?
        let loadFinished = expectation(description: "Load finished")
        
        storage.loadEvents {
            restoredEvent = $0.first
            loadFinished.fulfill()
        }
        
        wait(for: [loadFinished], timeout: 0.1)
        
        XCTAssertNil(restoredEvent)
    }
    
    func testRemoveEvent() throws {
        let event = StorableEvent(
            event: IdentifiableEvent(id: .init(), event: BatchEventMock()),
            contextId: .init()
        )
        
        storage.storeEvent(event)
        try reinitStorage()
        storage.removeEvent(with: event.event.id)
        
        try reinitStorage()
        var restoredEvent: StorableEvent?
        let loadFinished = expectation(description: "Load finished")
        
        storage.loadEvents {
            restoredEvent = $0.first
            loadFinished.fulfill()
        }
        
        wait(for: [loadFinished], timeout: 0.1)
        
        XCTAssertNil(restoredEvent)
    }
    
    func testRemoveEventWrongId() throws {
        let event = StorableEvent(
            event: IdentifiableEvent(id: .init(), event: BatchEventMock()),
            contextId: .init()
        )
        
        storage.storeEvent(event)
        try reinitStorage()
        storage.removeEvent(with: UUID())
        
        try reinitStorage()
        var restoredEvent: StorableEvent?
        let loadFinished = expectation(description: "Load finished")
        
        storage.loadEvents {
            restoredEvent = $0.first
            loadFinished.fulfill()
        }
        
        wait(for: [loadFinished], timeout: 0.1)
        
        XCTAssertNotNil(restoredEvent)
    }
    
    func testLoadEvents() throws {
        let events = [
            BatchEventMock(shouldFailDeserialize: true),
            BatchEventMock(),
            BatchEventMock(shouldFailDeserialize: true),
            BatchEventMock(),
            BatchEventMock()
        ].map {
            StorableEvent(event: IdentifiableEvent(id: .init(), event: $0), contextId: .init())
        }
        
        events.forEach(storage.storeEvent)
        
        try reinitStorage()
        let loadCompleted = expectation(description: "Load completed")
        
        storage.loadEvents { events in
            XCTAssertEqual(events.count, 3)
            loadCompleted.fulfill()
        }
        
        wait(for: [loadCompleted], timeout: 0.1)
    }
    
    func testBatchStore() throws {
        let expectedEvents = (0...20).map {
            StorableEvent.mock(timestamp: $0)
        }
        
        let batch = BatchMock()
        
        expectedEvents.forEach(storage.storeEvent(_:))
        
        try reinitStorage()
        try storage.saveBatch(batch, with: expectedEvents[0...10].map { $0.event.id })

        try reinitStorage()
        let eventsLoaded = expectation(description: "Events loaded")

        storage.loadEvents { events in
            let sortedEvents = events.sorted(by: { $0.event.event.timestamp < $1.event.event.timestamp })

            XCTAssertEqual(sortedEvents.map { $0.event.id }, expectedEvents[11...20].map { $0.event.id })
            eventsLoaded.fulfill()
        }

        wait(for: [eventsLoaded], timeout: 0.05)
        
        XCTAssertEqual(try storage.loadBatch() as? BatchMock, batch)
    }
    
    func testBatchRemove() throws {
        let batch = BatchMock()

        try storage.saveBatch(batch, with: [])
        
        try reinitStorage()
        try storage.removeBatch()
        
        try reinitStorage()
        XCTAssertNil(try storage.loadBatch())
    }
    
    func testBatchLoadNoBatch() throws {
        XCTAssertNil(try storage.loadBatch())
    }
    
    private func reinitStorage() throws {
        storage = try SQLiteStorage(folderURL: testURL, stack: stackMock)
    }
}
