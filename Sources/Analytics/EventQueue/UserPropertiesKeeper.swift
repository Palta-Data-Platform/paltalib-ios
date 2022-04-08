//
//  UserPropertiesKeeper.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 08.04.2022.
//

import Foundation
import PaltaLibCore

protocol UserPropertiesProvider: AnyObject {
    var userId: String? { get }
    var deviceId: UUID? { get }
}

protocol UserPropertiesKeeper: UserPropertiesProvider {
    var userId: String? { get set }
    var deviceId: UUID? { get set }
}

final class UserPropertiesKeeperImpl: UserPropertiesKeeper {
    var userId: String? {
        get {
            userProperties?.userId
        }
        set {
            userProperties?.userId = newValue
        }
    }

    var deviceId: UUID? {
        get {
            userProperties?.deviceId
        }
        set {
            userProperties?.deviceId = newValue
        }
    }

    private lazy var userProperties: UserProperties? = userDefaults.object(for: defaultsKey) ?? UserProperties() {
        didSet {
            userDefaults.set(userProperties, for: defaultsKey)
        }
    }

    private let defaultsKey = "paltaBrainUserProperties"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}
