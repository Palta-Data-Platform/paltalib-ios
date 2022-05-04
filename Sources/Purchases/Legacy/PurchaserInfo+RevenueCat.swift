import Foundation
import Purchases

public extension PurchaserInfo {
    var internalRevenueCatInfo: Purchases.PurchaserInfo? {
        guard let adapter = self as? PurchaserInfoRCAdapter else {
            return nil
        }

        return adapter.info
    }
}
