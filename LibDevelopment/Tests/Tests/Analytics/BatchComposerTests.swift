//
//  BatchComposerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class BatchComposerTests: XCTestCase {
    private var composer: BatchComposerImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        composer = .init()
    }
    
    func testComposeBatch() throws {
        let events: [Event] = [.mock(), .mock()]
        let telemetry = Telemetry.mock()
        
        let batch = composer.makeBatch(of: events, telemetry: telemetry)
        
        XCTAssertEqual(batch.events, events)
        XCTAssertEqual(batch.telemetry, telemetry)
    }
    
    func testEventsSorted() throws {
        let events: [Event] = [
            .mock(timestamp: 7),
            .mock(timestamp: 2),
            .mock(timestamp: 55),
            .mock(timestamp: 34)
        ]
        
        let batch = composer.makeBatch(of: events, telemetry: .mock())
        
        XCTAssertEqual(
            batch.events.map { $0.timestamp },
            [2, 7, 34, 55]
        )
    }
}
