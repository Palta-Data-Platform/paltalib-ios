//
//  BatchContext.swift
//  PaltaLibAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol BatchContext {
    init()
    init(data: Data) throws
    
    func serialize() throws -> Data
}
