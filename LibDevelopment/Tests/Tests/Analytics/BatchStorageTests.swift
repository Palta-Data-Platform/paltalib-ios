//
//  BatchStorageTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 16/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class BatchStorageTests: XCTestCase {
    private var stackMock: Stack!
    private var fileManager: FileManager!
    private var testURL: URL!
    
    private var storage: BatchStorageImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        stackMock = .mock
        
        fileManager = FileManager()
        testURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        try fileManager.createDirectory(at: testURL, withIntermediateDirectories: true)
        
        storage = BatchStorageImpl(folderURL: testURL, stack: stackMock, fileManager: fileManager)
    }
    
    override func tearDown() async throws {
        try fileManager.removeItem(at: testURL)
    }
    
    func testSaveBatch() throws {
        let batch = BatchMock()
        
        try storage.saveBatch(batch)
        
        XCTAssertEqual(
            try Data(contentsOf: testURL.appendingPathComponent("currentBatch")),
            batch.data
        )
    }
    
    func testSaveBatchError() {
        let batch = BatchMock(shouldFailSerialize: true)
        
        XCTAssertThrowsError(try storage.saveBatch(batch))
    }
    
    func testLoadBatch() throws {
        let batch = BatchMock()
        
        try storage.saveBatch(batch)
        
        let loadedBatch = try storage.loadBatch() as? BatchMock
        
        XCTAssertEqual(batch, loadedBatch)
    }
    
    func testLoadNoSavedBatch() throws {
        XCTAssertNil(try storage.loadBatch())
    }
    
    func testRemove() throws {
        let batch = BatchMock()
        
        try storage.saveBatch(batch)
        try storage.removeBatch()

        XCTAssertNil(try storage.loadBatch())
    }
    
    func testRemoveNoFile() throws {
        try storage.removeBatch()
    }
}
