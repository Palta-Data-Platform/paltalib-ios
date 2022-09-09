//
//  SDKInfoProviderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class SDKInfoProviderMock: SDKInfoProvider {
    var sdkName: String = "MOCK_NAME"
    var sdkVersion: String = "MOCK_VERSION"
}
