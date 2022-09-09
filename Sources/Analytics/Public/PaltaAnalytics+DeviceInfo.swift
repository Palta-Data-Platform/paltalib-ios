//
//  PaltaAnalytics+DeviceInfo.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 15/07/2022.
//

import Foundation

public extension PaltaAnalytics {
    static var deviceInfoProvider: DeviceInfoProvider {
        shared.assembly.analyticsCoreAssembly.deviceInfoProvider
    }
}
