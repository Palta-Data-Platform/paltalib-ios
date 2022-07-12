//
//  Batch.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import PaltaLibAnalytics
import PaltaAnlyticsTransport

extension PaltaAnlyticsTransport.Batch: PaltaLibAnalytics.Batch {
    public init(
        common: PaltaLibAnalytics.BatchCommon,
        context: PaltaLibAnalytics.BatchContext,
        events: [BatchEvent]
    ) {
        guard
            let common = common as? PaltaAnlyticsTransport.BatchCommon,
            let context = (context as? Context)?.message,
            let events = events as? [PaltaAnlyticsTransport.Event]
        else {
            assertionFailure()
            self = .init()
            return
        }
        
        self.init()
        
        self.common = common
        self.context = context
        self.events = events
    }
    
    public init(data: Data) throws {
        try self.init(serializedData: data)
    }
    
    public func serialize() throws -> Data {
        try serializedData()
    }
}
