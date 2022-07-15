//
//  BatchCommonMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 16/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel
import PaltaLibAnalytics

struct BatchCommonMock: BatchCommon, Equatable {
    let instanceId: UUID
    let batchId: UUID
    let countryCode: String
    let locale: Locale
    let utcOffset: Int64
}
