//
//  EnvironmentSetupViewModel.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 01/11/2022.
//

import Combine
import Foundation

final class EnvironmentSetupViewModel {
    var paymentsHostPlaceholder: String {
        environmentSettingsService.defaultPaymentsHost.absoluteString
    }
    
    var paymentsKeyPlaceholder: String {
        environmentSettingsService.defaultPaymentsApiKey
    }
    
    var analyticsHostPlaceholder: String {
        environmentSettingsService.defaultAnalyticsHost.absoluteString
    }
    
    var analyticsKeyPlaceholder: String {
        environmentSettingsService.defaultAnalyticsApiKey
    }
    
    @Published
    var analyticsHost: String?
    
    @Published
    var analyticsKey: String?
    
    @Published
    var paymentsHost: String?
    
    @Published
    var paymentsKey: String?
    
    @Published
    var isReady: Bool = false
    
    @Published
    private var analyticsURL: URL?
    
    @Published
    private var paymentsURL: URL?
    
    private let environmentSettingsService: EnvironmentSettingsService = .shared
    
    private var cancels: Set<AnyCancellable> = []
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        analyticsHost = environmentSettingsService.customAnalyticsHost?.absoluteString
        analyticsKey = environmentSettingsService.customAnalyticsApiKey
        paymentsHost = environmentSettingsService.customPaymentsHost?.absoluteString
        paymentsKey = environmentSettingsService.customPaymentsApiKey
        
        $analyticsHost
            .map { $0.flatMap { URL(string: $0) } }
            .assign(to: &$analyticsURL)
        
        $paymentsHost
            .map { $0.flatMap { URL(string: $0) } }
            .assign(to: &$paymentsURL)
        
        Publishers
            .CombineLatest4(
                $analyticsURL,
                $analyticsKey,
                $paymentsURL,
                $paymentsKey
            )
            .map { (analyticsURL: URL?, analyticsKey: String?, paymentsURL: URL?, paymentsKey: String?) in
                ((analyticsURL == nil) == (analyticsKey?.isEmpty != false)) && ((paymentsURL == nil) == (paymentsKey?.isEmpty != false))
            }
            .assign(to: &$isReady)
    }
    
    func commit() {
        environmentSettingsService.customAnalyticsHost = analyticsURL
        environmentSettingsService.customAnalyticsApiKey = analyticsKey
        
        environmentSettingsService.customPaymentsHost = paymentsURL
        environmentSettingsService.customPaymentsApiKey = paymentsKey
        
        exit(0)
    }
}
