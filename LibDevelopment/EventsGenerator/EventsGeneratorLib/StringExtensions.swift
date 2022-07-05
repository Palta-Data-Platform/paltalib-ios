//
//  StringExtensions.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation

extension String {
    var startLowercase: String {
        guard let first = first else {
            return ""
        }
        
        return first.lowercased() + suffix(from: index(after: startIndex))
    }
}
