import Foundation
import Purchases

public extension PurchaserInfo {
    public var internalRevenueCatInfo: Purchases.PurchaserInfo? {
        guard let adapter = self as? PurchaserInfoRCAdapter else {
            return nil
        }

        return adapter.info
    }
}
