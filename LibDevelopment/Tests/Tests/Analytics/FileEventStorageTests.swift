//
//  FileEventStorageTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import XCTest
@testable import PaltaLibAnalytics

final class FileEventStorageTests: XCTestCase {
    private var url: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        url = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("PaltaBrainEvents")
        try? FileManager.default.removeItem(at: url)
    }

    func testStoreAndLoad() {
        let originalEvents = (0...20).map {
            Event.mock(uuid: UUID(), timestamp: $0)
        }

        let storage1 = FileEventStorage(folderURL: url)

        originalEvents.forEach {
            storage1.storeEvent($0)
        }

        let storageFinished = expectation(description: "Storage finished writing")
        storage1.addBarrier(storageFinished.fulfill)
        wait(for: [storageFinished], timeout: 0.1)

        let storage2 = FileEventStorage(folderURL: url)

        let eventsLoaded = expectation(description: "Events loaded")

        storage2.loadEvents { events in
            let sortedEvents = events.sorted(by: { $0.timestamp < $1.timestamp })

            XCTAssertEqual(sortedEvents, originalEvents)
            eventsLoaded.fulfill()
        }

        wait(for: [eventsLoaded], timeout: 0.05)
    }

    func testRemoveOnSameInstance() {
        let originalEvents = (0...20).map {
            Event.mock(uuid: UUID(), timestamp: $0)
        }

        let storage1 = FileEventStorage(folderURL: url)

        originalEvents.forEach {
            storage1.storeEvent($0)
        }

        let removedEvent = originalEvents.randomElement()!
        storage1.removeEvent(removedEvent)

        let storageFinished = expectation(description: "Storage finished writing")
        storage1.addBarrier(storageFinished.fulfill)
        wait(for: [storageFinished], timeout: 0.1)

        let storage2 = FileEventStorage(folderURL: url)

        let eventsLoaded = expectation(description: "Events loaded")
        let expectedEvents = originalEvents.filter { $0 != removedEvent }

        storage2.loadEvents { events in
            let sortedEvents = events.sorted(by: { $0.timestamp < $1.timestamp })

            XCTAssertEqual(sortedEvents, expectedEvents)
            eventsLoaded.fulfill()
        }

        wait(for: [eventsLoaded], timeout: 0.05)
    }

    func testRemoveOnNewInstance() {
        let originalEvents = (0...20).map {
            Event.mock(uuid: UUID(), timestamp: $0)
        }

        let storage1 = FileEventStorage(folderURL: url)

        originalEvents.forEach {
            storage1.storeEvent($0)
        }

        let storageFinished = expectation(description: "Storage finished writing")
        storage1.addBarrier(storageFinished.fulfill)
        wait(for: [storageFinished], timeout: 0.1)

        let storage2 = FileEventStorage(folderURL: url)

        let removedEvent = originalEvents.randomElement()!
        storage2.removeEvent(removedEvent)

        let eventsLoaded = expectation(description: "Events loaded")
        let expectedEvents = originalEvents.filter { $0 != removedEvent }

        storage2.loadEvents { events in
            let sortedEvents = events.sorted(by: { $0.timestamp < $1.timestamp })

            XCTAssertEqual(sortedEvents, expectedEvents)
            eventsLoaded.fulfill()
        }

        wait(for: [eventsLoaded], timeout: 0.05)
    }

    func testSavePerformance() {
        measure {
            let storage = FileEventStorage(folderURL: url)
            (0...5000).forEach {
                storage.storeEvent(.mock(uuid: UUID(), timestamp: $0))
            }

            let group = DispatchGroup()
            group.enter()
            storage.addBarrier(group.leave)
            group.wait()
        }
    }
    
    func testRemovePerformance() {
        let events: [Event] = (0...5000).map {
            .mock(uuid: UUID(), timestamp: $0)
        }
        measure {
            let storage = FileEventStorage(folderURL: url)
            events.forEach {
                storage.storeEvent($0)
            }
            
            
            let group = DispatchGroup()
            group.enter()
            storage.addBarrier(group.leave)
            group.wait()
            
            events.forEach {
                storage.removeEvent($0)
            }

            let group2 = DispatchGroup()
            group2.enter()
            storage.addBarrier(group2.leave)
            group2.wait()
        }
    }

    func testLoadPerformance() {
        let storage = FileEventStorage(folderURL: url)
        (0...5000).forEach {
            storage.storeEvent(.mock(timestamp: $0))
        }

        let storageFinished = expectation(description: "Storage finished writing")
        storage.addBarrier(storageFinished.fulfill)
        wait(for: [storageFinished], timeout: 100)

        measure {
            let group = DispatchGroup()
            group.enter()

            FileEventStorage(folderURL: url).loadEvents { _ in
                group.leave()
            }

            group.wait()
        }
    }
}
