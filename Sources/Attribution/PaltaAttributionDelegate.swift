//
//  PaltaAttributionDelegate.swift
//  PaltaLibAttribution
//
//  Created by Vyacheslav Beltyukov on 22/06/2022.
//

import Foundation

public protocol PaltaAttributionDelegate: AnyObject {
    func didReceiveUserID(_ attribution: PaltaAttribution, userID: String)
    func didReceive(_ attribution: PaltaAttribution, userData: PaltaAttribution.UserData)
    func didReceiveConversion(_ attribution: PaltaAttribution, with result: Result<[AnyHashable: Any], Error>)
    func didReceiveAttributionInfo(_ attribution: PaltaAttribution, with result: Result<[AnyHashable: Any], Error>)
    func didReceiveDeepLink(_ attribution: PaltaAttribution, deepLink: PaltaAttribution.DeepLink)
}

public extension PaltaAttributionDelegate {
    func didReceiveUserID(_ attribution: PaltaAttribution, userID: String) {}
    func didReceive(_ attribution: PaltaAttribution, userData: PaltaAttribution.UserData) {}
}
