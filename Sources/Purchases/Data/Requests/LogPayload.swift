//
//  LogPayload.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 04/09/2022.
//

import Foundation
import PaltaLibCore

struct LogPayload: Encodable {
    enum Level: String, Encodable, Equatable {
        case error
        case warning
        case info
    }
    
    let level: Level
    let eventName: String
    let data: CodableDictionary?
}
