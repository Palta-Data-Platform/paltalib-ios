import Foundation

extension PaltaPurchases {

    struct Configuration {
        let revenueCatApiKey: String
        let revenueCatUserID: String?
        let revenueCatDebugLogsEnabled: Bool
        let webSubscriptionID: String?

        public init(revenueCatApiKey: String,
                    revenueCatUserID: String?,
                    revenueCatDebugLogsEnabled: Bool,
                    webSubscriptionID: String?) {
            self.revenueCatApiKey = revenueCatApiKey
            self.revenueCatUserID = revenueCatUserID
            self.revenueCatDebugLogsEnabled = revenueCatDebugLogsEnabled
            self.webSubscriptionID = webSubscriptionID
        }
    }
}
