//
//  DateFormatter.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

public extension DateFormatter {
    convenience init(_ format: String, timeZone: TimeZone? = TimeZone(secondsFromGMT: 0)) {
        self.init()
        
        self.timeZone = timeZone
        self.dateFormat = format
    }
}
