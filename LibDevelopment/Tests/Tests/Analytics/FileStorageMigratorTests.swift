//
//  FileStorageMigratorTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 02/12/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class FileStorageMigratorTests: XCTestCase {
    private var fileManager: FileManager!
    private var testURL: URL!
    private var storageMock: EventStorageMock!
    
    private var migrator: FileStorageMigrator!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        fileManager = FileManager()
        testURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        try fileManager.createDirectory(at: testURL, withIntermediateDirectories: true)
        
        storageMock = EventStorageMock()
        
        migrator = FileStorageMigrator(folderURL: testURL, newStorage: storageMock)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        try fileManager.removeItem(at: testURL)
    }
    
    func testMigration() throws {
        let expectedEvents = try populateValidEvents()
        
        try migrator.migrateEvents()
        
        XCTAssertEqual(Set(storageMock.addedEvents), expectedEvents)
    }
    
    func testMigrationOnlyOnce() throws {
        try populateValidEvents()
        
        try migrator.migrateEvents()
        storageMock.addedEvents = []
        try migrator.migrateEvents()
        
        XCTAssert(storageMock.addedEvents.isEmpty)
    }
    
    func testInvalidFiles() throws {
        try populateInvalidEvents()
        
        try migrator.migrateEvents()
        
        XCTAssert(storageMock.addedEvents.isEmpty)
    }
    
    func testValidAndInvalidEvents() throws {
        try populateInvalidEvents()
        let expectedEvents = try populateValidEvents()
        
        try migrator.migrateEvents()
        
        XCTAssertEqual(Set(storageMock.addedEvents), expectedEvents)
    }
    
    @discardableResult
    private func populateValidEvents() throws -> Set<Event> {
        let encoder = JSONEncoder()
        let events = Set(
            (0...9).map { _ in
                Event.mock(uuid: UUID())
            }
        )
        
        try events
            .forEach {
                let url = testURL.appendingPathComponent("\($0.insertId).event")
                let data = try encoder.encode($0)
                try data.write(to: url)
            }
        
        return events
    }
    
    private func populateInvalidEvents() throws {
        let encoder = JSONEncoder()
        try (0...9).map {
            Data([$0])
        }
        .forEach {
            let url = testURL.appendingPathComponent("\(UUID()).event")
            try $0.write(to: url)
        }
    }
}
