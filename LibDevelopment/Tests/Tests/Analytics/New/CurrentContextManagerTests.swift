//
//  CurrentContextManagerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 24/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class CurrentContextManagerTests: XCTestCase {
    private var storageMock: ContextStorageMock!
    private var stackMock: Stack!
    
    private var manager: CurrentContextManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        storageMock = .init()
        stackMock = .mock
        
        manager = CurrentContextManager(stack: stackMock, storage: storageMock)
    }
    
    func testModifyContext() {
        let currentId = manager.currentContextId
        
        manager.editContext { (context: inout BatchContextMock) in
            context.mockFieldA = 88
            context.mockFieldB = 120
        }
        
        let newContext = manager.context as? BatchContextMock
        
        XCTAssertEqual(newContext?.mockFieldA, 88)
        XCTAssertEqual(newContext?.mockFieldB, 120)
        XCTAssertNotEqual(manager.currentContextId, currentId)
        XCTAssertEqual((storageMock.savedContexts.first as? BatchContextMock)?.mockFieldA, 88)
        XCTAssertEqual(storageMock.savedContextsIds.first, manager.currentContextId)
    }
    
    func testModifyContextConcurrently() {
        DispatchQueue.concurrentPerform(iterations: 50) { index in
            manager.editContext { (context: inout BatchContextMock) in
                context.mockFieldA = index
                context.mockFieldB = index * 2
            }
        
        }
        
        let uniqueChecksums = Set(
            storageMock.savedContexts
                .compactMap { $0 as? BatchContextMock }
                .map { $0.mockFieldA * 1000 + $0.mockFieldB }
        )
        
        let uniqueIds = Set(storageMock.savedContextsIds)
        
        XCTAssertEqual(storageMock.savedContexts.count, 50)
        XCTAssertEqual(uniqueChecksums.count, 50)
        XCTAssertEqual(uniqueIds.count, 50)
    }
    
    func testStripContexts() {
        let ids: Set<UUID> = [UUID(), UUID()]
        manager.stripContexts(excluding: ids)
        
        XCTAssertEqual(storageMock.stripContextsIds, ids)
    }
}
