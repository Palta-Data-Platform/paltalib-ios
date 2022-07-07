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
}
