//
//  BatchContextMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 16/06/2022.
//

import Foundation
import PaltaLibAnalytics

struct BatchContextMock: BatchContext {
    let initiatedFromData: Bool
    let data: Data
    
    var mockFieldA = 0
    var mockFieldB = 0
    
    init() {
        self.initiatedFromData = false
        self.data = Data((0...20).map { _ in UInt8.random(in: 0...255) })
    }
    
    init(data: Data) throws {
        self.initiatedFromData = true
        self.data = data
    }
    
    func serialize() throws -> Data {
        return data
    }
}
