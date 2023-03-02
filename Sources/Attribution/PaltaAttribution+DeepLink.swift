import Foundation

public extension PaltaAttribution {
    struct DeepLink {
        public let clickEvent: [String: Any]
        public let deeplinkValue: String?
        public let matchType: String?
        public let clickHTTPReferrer: String?
        public let mediaSource: String?
        public let campaign: String?
        public let campaignId: String?
        public let afSub1: String?
        public let afSub2: String?
        public let afSub3: String?
        public let afSub4: String?
        public let afSub5: String?
        public let isDeferred: Bool
        
        public var voucherId: String? {
            guard
                let deeplinkValue = deeplinkValue,
                Constants.webSubscriptionDeeplinkTypes.keys.contains(deeplinkValue)
            else {
                return nil
            }
            
            return clickEvent[Constants.deepLinkVoucherIdKey] as? String
        }
    }
}
