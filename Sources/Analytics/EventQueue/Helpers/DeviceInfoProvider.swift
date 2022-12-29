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

protocol DeviceInfoProvider {
    var osVersion: String { get }
    var appVersion: String? { get }
    var deviceModel: String { get }
    var carrier: String { get }
    var country: String? { get }
    var language: String? { get }
    var timezoneOffset: Int { get }
    var idfa: String? { get }
    var idfv: String? { get }
}

final class DeviceInfoProviderImpl: DeviceInfoProvider {
    var osVersion: String {
        UIDevice.current.systemVersion
    }

    var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    let deviceModel: String = {
        let deviceName: String = "hw.machine".withCString { cString in
            var size: Int = 0
            sysctlbyname(cString, nil, &size, nil, 0)
            
            var data = Data(count: size)
            return data.withUnsafeMutableBytes { pointer in
                sysctlbyname(cString, pointer.baseAddress, &size, nil, 0)
                
                guard let rawPointer = pointer.baseAddress else {
                    return ""
                }
                
                let opaquePointer = OpaquePointer(rawPointer)
                
                return String(cString: UnsafePointer<CChar>(opaquePointer))
            }
        }
        
        return DeviceInfoProviderImpl.deiviceModelMapping[deviceName] ?? deviceName
    }()

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

    var idfa: String? {
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != .authorized  {
                return nil
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == false {
                return nil
            }
        }

        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    private(set) var idfv: String? = {
        let closure = { UIDevice.current.identifierForVendor?.uuidString }

        if Thread.isMainThread {
            return closure()
        } else {
            return DispatchQueue.main.sync(execute: closure)
        }
    }()
}

extension DeviceInfoProviderImpl {
    private static let deiviceModelMapping: [String: String] = [
        "i386" : "iPhone Simulator",
        "x86_64" : "iPhone Simulator",
        "arm64" : "iPhone Simulator",
        "iPhone1,1" : "iPhone 1",
        "iPhone1,2" : "iPhone 3G",
        "iPhone2,1" : "iPhone 3GS",
        "iPhone3,1" : "iPhone 4",
        "iPhone3,2" : "iPhone 4",
        "iPhone3,3" : "iPhone 4",
        "iPhone4,1" : "iPhone 4S",
        "iPhone5,1" : "iPhone 5",
        "iPhone5,2" : "iPhone 5",
        "iPhone5,3" : "iPhone 5c",
        "iPhone5,4" : "iPhone 5c",
        "iPhone6,1" : "iPhone 5s",
        "iPhone6,2" : "iPhone 5s",
        "iPhone7,1" : "iPhone 6 Plus",
        "iPhone7,2" : "iPhone 6",
        "iPhone8,1" : "iPhone 6s",
        "iPhone8,2" : "iPhone 6s Plus",
        "iPhone8,4" : "iPhone SE",
        "iPhone9,1" : "iPhone 7",
        "iPhone9,2" : "iPhone 7 Plus",
        "iPhone9,3" : "iPhone 7",
        "iPhone9,4" : "iPhone 7 Plus",
        "iPhone10,1" : "iPhone 8",
        "iPhone10,2" : "iPhone 8 Plus",
        "iPhone10,3" : "iPhone X",
        "iPhone10,4" : "iPhone 8",
        "iPhone10,5" : "iPhone 8 Plus",
        "iPhone10,6" : "iPhone X",
        "iPhone11,2" : "iPhone XS",
        "iPhone11,4" : "iPhone XS Max",
        "iPhone11,6" : "iPhone XS Max",
        "iPhone11,8" : "iPhone XR",
        "iPhone12,1" : "iPhone 11",
        "iPhone12,3" : "iPhone 11 Pro",
        "iPhone12,5" : "iPhone 11 Pro Max",
        "iPhone12,8" : "iPhone SE 2",
        "iPhone13,1" : "iPhone 12 Mini",
        "iPhone13,2" : "iPhone 12",
        "iPhone13,3" : "iPhone 12 Pro",
        "iPhone13,4" : "iPhone 12 Pro Max",
        "iPhone14,2" : "iPhone 13 Pro",
        "iPhone14,3" : "iPhone 13 Pro Max",
        "iPhone14,4" : "iPhone 13 Mini",
        "iPhone14,5" : "iPhone 13",
        "iPhone14,6" : "iPhone SE 3",
        "iPhone14,7" : "iPhone 14",
        "iPhone14,8" : "iPhone 14 Plus",
        "iPhone15,2" : "iPhone 14 Pro",
        "iPhone15,3" : "iPhone 14 Pro Max",
        
        "iPod1,1" : "iPod Touch 1G",
        "iPod2,1" : "iPod Touch 2G",
        "iPod3,1" : "iPod Touch 3G",
        "iPod4,1" : "iPod Touch 4G",
        "iPod5,1" : "iPod Touch 5G",
        "iPod7,1" : "iPod Touch 6G",
        "iPod9,1" : "iPod Touch 7G",
        
        "iPad1,1" : "iPad",
        "iPad1,2" : "iPad",
        "iPad2,1" : "iPad 2",
        "iPad2,2" : "iPad 2",
        "iPad2,3" : "iPad 2",
        "iPad2,4" : "iPad 2",
        "iPad3,1" : "iPad 3",
        "iPad3,2" : "iPad 3",
        "iPad3,3" : "iPad 3",
        "iPad2,5" : "iPad Mini",
        "iPad2,6" : "iPad Mini",
        "iPad2,7" : "iPad Mini",
        "iPad3,4" : "iPad 4",
        "iPad3,5" : "iPad 4",
        "iPad3,6" : "iPad 4",
        "iPad4,1" : "iPad Air",
        "iPad4,2" : "iPad Air",
        "iPad4,3" : "iPad Air",
        "iPad4,4" : "iPad Mini 2",
        "iPad4,5" : "iPad Mini 2",
        "iPad4,6" : "iPad Mini 2",
        "iPad4,7" : "iPad Mini 3",
        "iPad4,8" : "iPad Mini 3",
        "iPad4,9" : "iPad Mini 3",
        "iPad5,1" : "iPad Mini 4",
        "iPad5,2" : "iPad Mini 4",
        "iPad5,3" : "iPad Air 2",
        "iPad5,4" : "iPad Air 2",
        "iPad6,3" : "iPad Pro",
        "iPad6,4" : "iPad Pro",
        "iPad6,7" : "iPad Pro",
        "iPad6,8" : "iPad Pro",
        "iPad6,11" : "iPad 5",
        "iPad6,12" : "iPad 5",
        "iPad7,1" : "iPad Pro",
        "iPad7,2" : "iPad Pro",
        "iPad7,3" : "iPad Pro",
        "iPad7,4" : "iPad Pro",
        "iPad7,5" : "iPad 6",
        "iPad7,6" : "iPad 6",
        "iPad7,11" : "iPad 7",
        "iPad7,12" : "iPad 7",
        "iPad8,1" : "iPad Pro",
        "iPad8,2" : "iPad Pro",
        "iPad8,3" : "iPad Pro",
        "iPad8,4" : "iPad Pro",
        "iPad8,5" : "iPad Pro",
        "iPad8,6" : "iPad Pro",
        "iPad8,7" : "iPad Pro",
        "iPad8,8" : "iPad Pro",
        "iPad8,9" : "iPad Pro",
        "iPad8,10" : "iPad Pro",
        "iPad8,11" : "iPad Pro",
        "iPad8,12" : "iPad Pro",
        "iPad11,1" : "iPad Mini 5",
        "iPad11,2" : "iPad Mini 5",
        "iPad11,3" : "iPad Air 3",
        "iPad11,4" : "iPad Air 3",
        "iPad11,6" : "iPad 8",
        "iPad11,7" : "iPad 8",
        "iPad12,1" : "iPad 9",
        "iPad12,2" : "iPad 9",
        "iPad14,1" : "iPad Mini 6",
        "iPad14,2" : "iPad Mini 6",
        "iPad13,1" : "iPad Air 4",
        "iPad13,2" : "iPad Air 4",
        "iPad13,4" : "iPad Pro",
        "iPad13,5" : "iPad Pro",
        "iPad13,6" : "iPad Pro",
        "iPad13,7" : "iPad Pro",
        "iPad13,8" : "iPad Pro",
        "iPad13,9" : "iPad Pro",
        "iPad13,10" : "iPad Pro",
        "iPad13,11" : "iPad Pro",
        "iPad13,16" : "iPad Air",
        "iPad13,17" : "iPad Air",
        "iPad13,18" : "iPad 10",
        "iPad13,19" : "iPad 10",
        "iPad14,3-A" : "iPad Pro",
        "iPad14,3-B" : "iPad Pro",
        "iPad14,4-A" : "iPad Pro",
        "iPad14,4-B" : "iPad Pro",
        "iPad14,5-A" : "iPad Pro",
        "iPad14,5-B" : "iPad Pro",
        "iPad14,6-A" : "iPad Pro",
        "iPad14,6-B" : "iPad Pro"
    ]
}
