//
//  ContextStorageTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 23/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class ContextStorageTests: XCTestCase {
    private var stackMock: Stack!
    private var fileManager: FileManager!
    private var testURL: URL!
    
    var storage: ContextStorageImpl!
    
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
        
        storage = ContextStorageImpl(
            folderURL: testURL,
            stack: stackMock,
            fileManager: fileManager
        )
    }
    
    override func tearDown() async throws {
        try fileManager.removeItem(at: testURL)
    }
    
    func testRetrieveNoContext() {
        let context = storage.context(with: UUID()) as? BatchContextMock
        XCTAssertEqual(context?.initiatedFromData, false)
    }
    
    func testRetrieveExistingContext() throws {
        let id = UUID()
        try Data().write(to: testURL.appendingPathComponent("\(id).context"))
        
        let context = storage.context(with: id) as? BatchContextMock
        XCTAssertEqual(context?.initiatedFromData, true)
    }
    
    func testStripContexts() throws {
        let id1 = UUID()
        let url1 = testURL.appendingPathComponent("\(id1).context")
        let id2 = UUID()
        let url2 = testURL.appendingPathComponent("\(id2).event")
        let id3 = UUID()
        let url3 = testURL.appendingPathComponent("\(id3)")
        let id4 = UUID()
        let url4 = testURL.appendingPathComponent("\(id4).context")
        let id5 = UUID()
        let url5 = testURL.appendingPathComponent("\(id5).context")
        let id6 = UUID()
        let url6 = testURL.appendingPathComponent("\(id6).event")
        
        try [url1, url2, url3, url4, url5, url6].forEach { try Data().write(to: $0) }
        
        try storage.stripContexts(excluding: [id1, id4])
        
        XCTAssert(fileManager.fileExists(atPath: url1.path))
        XCTAssert(fileManager.fileExists(atPath: url2.path))
        XCTAssert(fileManager.fileExists(atPath: url3.path))
        XCTAssert(fileManager.fileExists(atPath: url4.path))
        XCTAssertFalse(fileManager.fileExists(atPath: url5.path))
        XCTAssert(fileManager.fileExists(atPath: url6.path))
    }
    
    func testSaveContext() throws {
        let originalContext = BatchContextMock()
        let id = UUID()
        
        try storage.saveContext(originalContext, with: id)
        
        let retrievedContext = storage.context(with: id) as? BatchContextMock
        
        XCTAssertEqual(retrievedContext?.initiatedFromData, true)
        XCTAssertEqual(retrievedContext?.data, originalContext.data)
    }
}
