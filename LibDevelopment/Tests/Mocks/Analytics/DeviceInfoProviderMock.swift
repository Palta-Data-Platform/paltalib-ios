//
//  DeviceInfoProviderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 11.04.2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class DeviceInfoProviderMock: DeviceInfoProvider {
    var osVersion: String = "undefinedVersion"
    var appVersion: String = "version-mock" 
    var deviceModel: String = "undefinedModel"
    var carrier: String = "undefinedCarrier"
    var country: String?
    var language: String?
    var timezoneOffsetSeconds: Int = 0
    var idfa: String = "idfa="
    var idfv: String = "idfv="
}
