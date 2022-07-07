//
//  StorableEventTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/06/2022.
//

import Foundation
import XCTest
@testable import PaltaLibAnalytics

final class StorableEventTests: XCTestCase {
    func testSerializeDeserialize() throws {
        let eventId = UUID()
        let contextId = UUID()
        let eventMock = BatchEventMock()
        
        let originalEvent = StorableEvent(
            event: .init(id: eventId, event: eventMock),
            contextId: contextId
        )
        
        let data = try originalEvent.serialize()
        
        let recoveredEvent = try StorableEvent(data: data, eventType: BatchEventMock.self)
        
        XCTAssertEqual(recoveredEvent.event.id, eventId)
        XCTAssertEqual(recoveredEvent.contextId, contextId)
        XCTAssertEqual(recoveredEvent.event.event as? BatchEventMock, eventMock)
    }
    
    func testCorruptedJSON() {
        let jsonData = "{\"wrong\": \"key\"}".data(using: .utf8)!
        
        XCTAssertThrowsError(try StorableEvent(data: jsonData, eventType: BatchEventMock.self)) {
            XCTAssert($0 is DecodingError)
        }
    }
    
    func testFailProtobuf() {
        let mockEvent = BatchEventMock(shouldFailSerialize: true)
        
        XCTAssertThrowsError(
            try StorableEvent(
                event: .init(id: .init(), event: mockEvent),
                contextId: .init()
            ).serialize()
        )
    }
}
