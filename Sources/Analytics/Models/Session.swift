//
//  Session.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import Foundation

struct Session: Codable {
    var id: Int

    var lastEventTimestamp: Int = currentTimestamp()
    
    var currentEventNumber: Int = -1
    
    mutating func nextEventNumber() -> Int {
        currentEventNumber += 1
        return currentEventNumber
    }
}
