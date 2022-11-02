//
//  EnvironmentSettingsService.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 01/11/2022.
//

import Foundation

final class EnvironmentSettingsService {
    static let shared = EnvironmentSettingsService()
    
    var defaultAnalyticsHost: URL {
        URL(string: "https://telemetry.mobilesdk.dev.paltabrain.com")!
    }
    
    var defaultPaymentsHost: URL {
        URL(string: "https://api.payments.dev.paltabrain.com")!
    }
    
    var defaultAnalyticsApiKey: String {
        "0037c694a811422a88e2a3c5a90510e3"
    }
    
    var defaultPaymentsApiKey: String {
        "13ac16d7a83e42268c7f9abb7bcd6443"
    }
    
    var customAnalyticsHost: URL? {
        get {
            userDefaults.url(forKey: "customAnalyticsHost")
        }
        set {
            userDefaults.set(newValue, forKey: "customAnalyticsHost")
            userDefaults.synchronize()
        }
    }
    
    var customPaymentsHost: URL? {
        get {
            userDefaults.url(forKey: "customPaymentsHost")
        }
        set {
            userDefaults.set(newValue, forKey: "customPaymentsHost")
            userDefaults.synchronize()
        }
    }
    
    var customAnalyticsApiKey: String? {
        get {
            userDefaults.string(forKey: "customAnalyticsApiKey")
        }
        set {
            userDefaults.set(newValue, forKey: "customAnalyticsApiKey")
            userDefaults.synchronize()
        }
    }
    
    var customPaymentsApiKey: String? {
        get {
            userDefaults.string(forKey: "customPaymentsApiKey")
        }
        set {
            userDefaults.set(newValue, forKey: "customPaymentsApiKey")
            userDefaults.synchronize()
        }
    }
    
    var analyticsHost: URL {
        customAnalyticsHost ?? defaultAnalyticsHost
    }
    
    var paymentsHost: URL {
        customPaymentsHost ?? defaultPaymentsHost
    }
    
    var analyticsApiKey: String {
        customAnalyticsApiKey ?? defaultAnalyticsApiKey
    }
    
    var paymentsApiKey: String {
        customPaymentsApiKey ?? defaultPaymentsApiKey
    }
    
    private let userDefaults: UserDefaults = .standard
}
