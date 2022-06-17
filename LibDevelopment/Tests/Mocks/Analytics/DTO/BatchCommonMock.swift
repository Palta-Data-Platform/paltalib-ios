//
//  BatchCommonMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 16/06/2022.
//

import Foundation
import PaltaLibAnalytics

struct BatchCommonMock: BatchCommon {
    init(instanceId: UUID, batchId: UUID, countryCode: String, locale: Locale, utcOffset: Int64) {
    }
}
