//
//  SDKInfoProvider.swift
//  PaltaLibanalytics
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation

protocol SDKInfoProvider {
    var sdkName: String { get }
    var sdkVersion: String { get }
}

final class SDKInfoProviderImpl: SDKInfoProvider {
    var sdkName: String {
        "PALTABRAIN_IOS"
    }
    
    var sdkVersion: String {
        "3.1.0"
    }
}
