import Foundation
import UIKit

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
        if
            case let Result.success(conversionData) = result,
            let deepLinkValue = conversionData[Constants.deepLinkValueKey] as? String,
            let userIDType = Constants.webSubscriptionDeeplinkTypes[deepLinkValue],
            let userID = conversionData[Constants.deepLinkUserIdKey] as? String
        {
            delegate?.didReceiveUserID(self, userID: userID, of: userIDType)
            
            let userData = UserData(
                userId: userID,
                userIdType: userIDType,
                voucherId: conversionData[Constants.deepLinkVoucherIdKey] as? String
            )
            
            delegate?.didReceive(self, userData: userData)
        }
        delegate?.didReceiveConversion(self, with: result)
    }

    public func didReceiveAttributionInfo(_ adapter: PaltaAppsflyerAdapter, with result: Result<[AnyHashable: Any], Error>) {
        if
            case let Result.success(conversionData) = result,
            let deepLinkValue = conversionData[Constants.deepLinkValueKey] as? String,
            let userIDType = Constants.webSubscriptionDeeplinkTypes[deepLinkValue],
            let userID = conversionData[Constants.deepLinkUserIdKey] as? String
        {
            delegate?.didReceiveUserID(self, userID: userID, of: userIDType)
            
            let userData = UserData(
                userId: userID,
                userIdType: userIDType,
                voucherId: conversionData[Constants.deepLinkVoucherIdKey] as? String
            )
            
            delegate?.didReceive(self, userData: userData)
        }
        delegate?.didReceiveAttributionInfo(self, with: result)
    }

    public func didReceiveDeepLink(_ attribution: PaltaAppsflyerAdapter, deepLink: DeepLink) {
        if
            let userIDType = deepLink.deeplinkValue.flatMap({ Constants.webSubscriptionDeeplinkTypes[$0] }),
            let userID = deepLink.clickEvent[Constants.deepLinkUserIdKey] as? String
        {
            delegate?.didReceiveUserID(self, userID: userID, of: userIDType)
            
            let userData = UserData(
                userId: userID,
                userIdType: userIDType,
                voucherId: deepLink.voucherId
            )
            
            delegate?.didReceive(self, userData: userData)
        }
           
        delegate?.didReceiveDeepLink(self, deepLink: deepLink)
    }
}

extension PaltaAttribution {
    enum Constants {
        static let deepLinkUserIdKey = "deep_link_sub1"
        static let deepLinkVoucherIdKey = "deep_link_sub2"
        static let deepLinkValueKey = "deep_link_value"
        
        static let webSubscriptionDeeplinkTypes: [String: UserIDType] = [
            "web_subscription_revenue_cat_id": .revenueCat,
            "web_subscription_palta_payments_id": .paltaPayments
        ]
    }
}
