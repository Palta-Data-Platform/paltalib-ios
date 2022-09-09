//  

import Foundation
import PaltaLibAnalyticsModel
import PaltaAnlyticsTransport

extension PaltaAnlyticsTransport.Batch: PaltaLibAnalyticsModel.Batch {
    public init(common: PaltaLibAnalyticsModel.BatchCommon, context: PaltaLibAnalyticsModel.BatchContext, events: [BatchEvent]) {
        self.init()
        guard
            let common = common as? PaltaAnlyticsTransport.BatchCommon,
            let context = (context as? Context)?.message,
            let events = events as? [PaltaAnlyticsTransport.Event]
        else {
            assertionFailure()
            return
        }

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
