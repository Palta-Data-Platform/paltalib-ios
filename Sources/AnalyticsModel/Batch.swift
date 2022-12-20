//
//  Batch.swift
//  PaltaLibAnalyticsModel
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol Batch {
    var batchId: UUID { get }

    init(common: BatchCommon, context: BatchContext, events: [BatchEvent])
    init(data: Data) throws
    
    func serialize() throws -> Data
}
