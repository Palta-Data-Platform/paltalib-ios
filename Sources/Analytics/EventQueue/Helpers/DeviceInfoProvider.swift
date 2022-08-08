//
//  DeviceInfoProvider.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 08.04.2022.
//

import Foundation
import UIKit
import CoreTelephony
import AdSupport
import AppTrackingTransparency

public protocol DeviceInfoProvider {
    var osVersion: String { get }
    var appVersion: String { get }
    var deviceModel: String { get }
    var carrier: String { get }
    var country: String? { get }
    var language: String? { get }
    var timezoneOffsetSeconds: Int { get }
    var idfa: String { get }
    var idfv: String { get }
}

final class DeviceInfoProviderImpl: DeviceInfoProvider {
    var osVersion: String {
        UIDevice.current.systemVersion
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
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

    var timezoneOffsetSeconds: Int {
        TimeZone.current.secondsFromGMT()
    }

    var idfa: String {
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != .authorized  {
                return ""
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == false {
                return ""
            }
        }

        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    let idfv: String = {
        let closure = { UIDevice.current.identifierForVendor?.uuidString ?? "" }

        if Thread.isMainThread {
            return closure()
        } else {
            return DispatchQueue.main.sync(execute: closure)
        }
    }()
}
