//
//  BatchCommon.swift
//  AnalyticsDTOExample
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation
import PaltaLibAnalytics
import ProtobufExample

extension ProtobufExample.BatchCommon: PaltaLibAnalytics.BatchCommon {
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
