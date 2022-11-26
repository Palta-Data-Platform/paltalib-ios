//
//  BatchStorageTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class BatchStorageTests: XCTestCase {
    private var fileManager: FileManager!
    private var testURL: URL!
    
    private var storage: BatchStorageImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        fileManager = FileManager()
        testURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        try fileManager.createDirectory(at: testURL, withIntermediateDirectories: true)
        
        storage = BatchStorageImpl(folderURL: testURL, fileManager: fileManager)
    }
    
    override func tearDown() async throws {
        try fileManager.removeItem(at: testURL)
    }
    
    func testSaveBatch() throws {
        let batch = Batch.mock()
        
        try storage.saveBatch(batch)
        
        XCTAssertNoThrow(
            try Data(contentsOf: testURL.appendingPathComponent("currentBatch"))
        )
    }
    
    func testLoadBatch() throws {
        let batch = Batch.mock()
        
        try storage.saveBatch(batch)
        
        let loadedBatch = try storage.loadBatch()
        
        XCTAssertEqual(batch, loadedBatch)
    }
    
    func testLoadNoSavedBatch() throws {
        XCTAssertNil(try storage.loadBatch())
    }
    
    func testRemove() throws {
        let batch = Batch.mock()
        
        try storage.saveBatch(batch)
        try storage.removeBatch()

        XCTAssertNil(try storage.loadBatch())
    }
    
    func testRemoveNoFile() throws {
        try storage.removeBatch()
    }
}
