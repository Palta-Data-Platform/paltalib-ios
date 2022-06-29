//
//  BatchEventMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 16/06/2022.
//

import Foundation
import PaltaLibAnalytics

struct BatchEventMock: BatchEvent, Equatable {
    static func == (lhs: BatchEventMock, rhs: BatchEventMock) -> Bool {
        lhs.data == rhs.data
    }
    
    static let failingData = Data((0...20).map { _ in UInt8.random(in: 0...255) })
    
    var timestamp: Int = 0
    
    let common: EventCommon?
    let header: EventHeaderMock?
    let payload: EventPayloadMock?
    
    let shouldFailSerialize: Bool
    let data: Data
    
    init(shouldFailSerialize: Bool = false, shouldFailDeserialize: Bool = false) {
        self.common = nil
        self.header = nil
        self.payload = nil
        
        self.shouldFailSerialize = shouldFailSerialize
        self.data = shouldFailDeserialize
        ? Self.failingData
        : Data((0...20).map { _ in UInt8.random(in: 0...255) })
    }
    
    init(common: EventCommon, header: EventHeader, payload: EventPayload) {
        self.common = common
        self.header = header as? EventHeaderMock
        self.payload = payload as? EventPayloadMock
        
        self.shouldFailSerialize = false
        self.data = Data()
    }
    
    init(data: Data) throws {
        guard data != Self.failingData else {
            throw NSError(domain: "", code: 0)
        }
        
        self.common = nil
        self.header = nil
        self.payload = nil

        self.shouldFailSerialize = false
        self.data = data
    }
    
    func serialize() throws -> Data {
        if shouldFailSerialize {
            throw NSError(domain: "", code: 0)
        } else {
            return data
        }
    }
}
