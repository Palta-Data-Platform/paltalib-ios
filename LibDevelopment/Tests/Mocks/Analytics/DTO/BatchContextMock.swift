//
//  BatchContextMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 16/06/2022.
//

import Foundation
import PaltaLibAnalytics

struct BatchContextMock: BatchContext {
    init() {
    }
    
    init(data: Data) throws {
    }
    
    func serialize() throws -> Data {
        throw NSError()
    }
}
