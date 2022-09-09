//
//  UUIDGeneratorMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class UUIDGeneratorMock: UUIDGenerator {
    var uuids: [UUID] = []
    
    func generateUUID() -> UUID {
        uuids.popLast()!
    }
}
