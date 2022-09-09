//  

import Foundation
import PaltaLibAnalyticsModel
import PaltaAnlyticsTransport

extension PaltaAnlyticsTransport.BatchCommon: PaltaLibAnalyticsModel.BatchCommon {
    public init(
        instanceId: UUID,
        batchId: UUID,
        countryCode: String,
        locale: Locale,
        utcOffset: Int64
    ) {
        self.init()

        self.instanceID = instanceId.uuidString
        self.batchID = batchId.uuidString
        self.countryCode = countryCode
        self.locale = locale.identifier
        self.utcOffset = utcOffset
    }
}
