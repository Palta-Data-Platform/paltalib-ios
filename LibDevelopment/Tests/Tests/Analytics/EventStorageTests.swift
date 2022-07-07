//
//  EventStorageTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 21/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class EventStorageTests: XCTestCase {
    private var stackMock: Stack!
    private var fileManager: FileManager!
    private var testURL: URL!
    
    private var storage: EventStorageImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        stackMock = Stack(
            batchCommon: BatchCommonMock.self,
            context: BatchContextMock.self,
            batch: BatchMock.self,
            event: BatchEventMock.self
        )
        
        fileManager = FileManager()
        testURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        try fileManager.createDirectory(at: testURL, withIntermediateDirectories: true)
        
        storage = EventStorageImpl(
            folderURL: testURL,
            stack: stackMock,
            fileManager: fileManager
        )
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
        
        let barrierCalled = expectation(description: "Barrier called")
        
        storage.addBarrier { [fileManager, testURL] in
            XCTAssert(
                fileManager!.fileExists(
                    atPath: testURL!.appendingPathComponent("\(event.event.id).event").path)
            )
            
            barrierCalled.fulfill()
        }
        
        wait(for: [barrierCalled], timeout: 0.1)
    }
    
    func testSaveEventError() {
        let event = StorableEvent(
            event: IdentifiableEvent(id: .init(), event: BatchEventMock(shouldFailSerialize: true)),
            contextId: .init()
        )
        
        storage.storeEvent(event)
        
        let barrierCalled = expectation(description: "Barrier called")
        
        storage.addBarrier { [fileManager, testURL] in
            XCTAssertFalse(
                fileManager!.fileExists(
                    atPath: testURL!.appendingPathComponent("\(event.event.id).\(event.contextId).event").path)
            )
            
            barrierCalled.fulfill()
        }
        
        wait(for: [barrierCalled], timeout: 0.1)
    }
    
    func testRemoveEvent() throws {
        let event = StorableEvent(
            event: IdentifiableEvent(id: .init(), event: BatchEventMock()),
            contextId: .init()
        )
        
        storage.storeEvent(event)
        
        let barrierCalled1 = expectation(description: "Barrier called 1")
        storage.addBarrier(barrierCalled1.fulfill)
        wait(for: [barrierCalled1], timeout: 0.1)
        
        storage.removeEvent(with: event.event.id)
        
        let barrierCalled2 = expectation(description: "Barrier called 2")
        
        storage.addBarrier { [fileManager, testURL] in
            XCTAssertFalse(
                fileManager!.fileExists(
                    atPath: testURL!.appendingPathComponent("\(event.event.id).\(event.contextId).event").path)
            )
            
            barrierCalled2.fulfill()
        }
        
        wait(for: [barrierCalled2], timeout: 0.1)
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
