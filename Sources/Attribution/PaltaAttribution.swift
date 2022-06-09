import Foundation
import UIKit

public protocol PaltaAttributionDelegate: AnyObject {
    func didReceiveUserID(_ attribution: PaltaAttribution, userID: String)
    func didReceiveVoucherID(_ attribution: PaltaAttribution, voucherID: String)
    func didReceiveConversion(_ attribution: PaltaAttribution, with result: Result<[AnyHashable: Any], Error>)
    func didReceiveAttributionInfo(_ attribution: PaltaAttribution, with result: Result<[AnyHashable: Any], Error>)
    func didReceiveDeepLink(_ attribution: PaltaAttribution, deepLink: PaltaAttribution.DeepLink)
}

public final class PaltaAttribution {
    public static let instance = PaltaAttribution(appsflyerAdapter: PaltaAppsflyerAdapter.sharedInstance)

    public weak var delegate: PaltaAttributionDelegate?
    public var appsflyerUID: String { appsflyerAdapter.appsflyerUID }

    private let appsflyerAdapter: PaltaAppsflyerAdapter
    
    init(appsflyerAdapter: PaltaAppsflyerAdapter) {
        self.appsflyerAdapter = appsflyerAdapter

        appsflyerAdapter.delegate = self
    }

    public func configureWith(appsFlyerDevKey: String,
                              appleAppID: String,
                              userID: String?,
                              useUninstallSandbox: Bool) {
        configure(using:
                    .init(appsFlyerDevKey: appsFlyerDevKey,
                          appleAppID: appleAppID,
                          userID: userID,
                          useUninstallSandbox: useUninstallSandbox)
        )
    }

    func configure(using configuration: Configuration) {
        appsflyerAdapter.setupAppsflyerWith(devKey: configuration.appsFlyerDevKey, appleAppID: configuration.appleAppID)
        if let userID = configuration.userID {
            appsflyerAdapter.setCustomerUserID(userID)
        }
        appsflyerAdapter.setUseUninstallSandbox(configuration.useUninstallSandbox)
    }

    public func setCustomerID(_ customerID: String) {
        appsflyerAdapter.setCustomerUserID(customerID)
    }

    public func waitForATTUserAuthorization(with timeout: TimeInterval) {
        appsflyerAdapter.waitForATTUserAuthorization(with: timeout)
    }

    public func start() {
        appsflyerAdapter.start()
    }

    public func continueUserActivity(_ userActivity: NSUserActivity,
                              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return appsflyerAdapter.continueUserActivity(userActivity, restorationHandler: restorationHandler)
    }

    public func open(url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return appsflyerAdapter.open(url: url, options: options)
    }

    public func registerDeviceToken(_ deviceToken: Data) {
        appsflyerAdapter.registerUninstall(deviceToken: deviceToken)
    }
}

extension PaltaAttribution: PaltaAppsflyerAdapterDelegate {
    public func didReceiveConversion(_ adapter: PaltaAppsflyerAdapter, with result: Result<[AnyHashable: Any], Error>) {
        if case let Result.success(conversionData) = result,
           conversionData[Constants.deepLinkValueKey] as? String == Constants.webSubscriptionsDeeplinkValue {
             if let userID = conversionData[Constants.deepLinkUserIdKey] as? String {
                 delegate?.didReceiveUserID(self, userID: userID)
             }
             
             if let voucherID = conversionData[Constants.deepLinkVoucherIdKey] as? String {
                 delegate?.didReceiveVoucherID(self, voucherID: voucherID)
             }
        }
        delegate?.didReceiveConversion(self, with: result)
    }

    public func didReceiveAttributionInfo(_ adapter: PaltaAppsflyerAdapter, with result: Result<[AnyHashable: Any], Error>) {
        if case let Result.success(conversionData) = result,
           conversionData[Constants.deepLinkValueKey] as? String == Constants.webSubscriptionsDeeplinkValue {
            if let userID = conversionData[Constants.deepLinkUserIdKey] as? String {
                delegate?.didReceiveUserID(self, userID: userID)
            }
            
            if let voucherID = conversionData[Constants.deepLinkVoucherIdKey] as? String {
                delegate?.didReceiveVoucherID(self, voucherID: voucherID)
            }
        }
        delegate?.didReceiveAttributionInfo(self, with: result)
    }

    public func didReceiveDeepLink(_ attribution: PaltaAppsflyerAdapter, deepLink: DeepLink) {
        if deepLink.deeplinkValue == Constants.webSubscriptionsDeeplinkValue {
            if let userID = deepLink.clickEvent[Constants.deepLinkUserIdKey] as? String {
                delegate?.didReceiveUserID(self, userID: userID)
            }
            
            if let voucherID = deepLink.voucherId {
                delegate?.didReceiveVoucherID(self, voucherID: voucherID)
            }
        }
           
        delegate?.didReceiveDeepLink(self, deepLink: deepLink)
    }
}

extension PaltaAttribution {
    enum Constants {
        static let deepLinkUserIdKey = "deep_link_sub1"
        static let deepLinkVoucherIdKey = "deep_link_sub2"
        static let deepLinkValueKey = "deep_link_value"
        static let webSubscriptionsDeeplinkValue = "web_subscription_revenue_cat_id"
    }
}
