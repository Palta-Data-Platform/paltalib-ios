//
//  DeviceInfoProvider.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 08.04.2022.
//

import Foundation
import UIKit
import CoreTelephony

protocol DeviceInfoProvider {
    var osVersion: String { get }
    var appVersion: String? { get }
    var deviceModel: String { get }
    var carrier: String { get }
    var country: String? { get }
    var language: String? { get }
    var timezoneOffset: Int { get }
}

final class DeviceInfoProviderImpl: DeviceInfoProvider {
    var osVersion: String {
        UIDevice.current.systemVersion
    }

    var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var deviceModel: String {
        UIDevice.current.model
    }

    var carrier: String {
        CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? "Unknown"
    }

    var country: String? {
        Locale.current.regionCode
    }

    var language: String? {
        Locale.current.languageCode
    }

    var timezoneOffset: Int {
        TimeZone.current.secondsFromGMT() / 3600
    }
}
