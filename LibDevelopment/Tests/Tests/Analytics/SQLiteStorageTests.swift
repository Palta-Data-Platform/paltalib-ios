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
        
        storage = try SQLiteStorage(folderURL: testURL, stack: stackMock)
    }
    
    override func tearDown() async throws {
        try fileManager.removeItem(at: testURL)
    }
    
    func testSaveEvent() {
        let event = StorableEvent(
            event: IdentifiableEvent(id: .init(), event: BatchEventMock()),
            contextId: .init()
        )
        
        storage.storeEvent(event)
        
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
    
    func testSaveEventError() {
        let event = StorableEvent(
            event: IdentifiableEvent(id: .init(), event: BatchEventMock(shouldFailSerialize: true)),
            contextId: .init()
        )
        
        storage.storeEvent(event)
        
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
        storage.removeEvent(with: event.event.id)
        
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
        storage.removeEvent(with: UUID())
        
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
        
        let loadCompleted = expectation(description: "Load completed")
        
        storage.loadEvents { events in
            XCTAssertEqual(events.count, 3)
            loadCompleted.fulfill()
        }
        
        wait(for: [loadCompleted], timeout: 0.1)
    }
}
