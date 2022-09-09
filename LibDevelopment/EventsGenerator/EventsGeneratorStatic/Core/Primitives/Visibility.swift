//
//  Visibility.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

enum Visibility: String {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
    case `open`
    
    var order: Int {
        switch self {
        case .open:
            return 0
        case .public:
            return 5
        case .internal:
            return 10
        case .fileprivate:
            return 15
        case .private:
            return 20
        }
    }
}
