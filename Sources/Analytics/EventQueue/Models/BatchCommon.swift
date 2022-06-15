//
//  BatchCommon.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06/06/2022.
//

import Foundation

public protocol BatchCommon {
    init(
        instanceId: UUID,
        batchId: UUID,
        countryCode: String,
        locale: Locale,
        utcOffset: Int64
    )
}
