import Foundation
import Purchases

final class ObserverContainer<T> {
    let action: (T) -> Void

    init(action: @escaping (T) -> Void) {
        self.action = action
    }
}

typealias TokenType = AnyObject

final class PurchaserInfoListener: NSObject {
    var purchaseInfoObservers: [() -> ObserverContainer<Purchases.PurchaserInfo>?] = []
    var promoPurchaseObservers: [() -> ObserverContainer<(SKProduct, RCDeferredPromotionalPurchaseBlock)>?] = []

    func subscribeOnPurchaserInfoUpdated(_ onUpdated: @escaping (Purchases.PurchaserInfo) -> Void) -> TokenType {
        let observer = ObserverContainer(action: onUpdated)
        let weakWrapped = { [weak observer] in return observer }
        purchaseInfoObservers.append(weakWrapped)
        return observer
    }

    func subscribeOnPromoProductPurchase(_ onPurchase: @escaping (SKProduct, @escaping RCDeferredPromotionalPurchaseBlock) -> Void) -> TokenType {
        let observer = ObserverContainer(action: onPurchase)
        let weakWrapped = {  [weak observer] in return observer }
        promoPurchaseObservers.append(weakWrapped)
        return observer
    }
}

extension PurchaserInfoListener: PurchasesDelegate {
    func purchases(_: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        purchaseInfoObservers.forEach { $0()?.action(purchaserInfo) }
    }

    func purchases(_ purchases: Purchases,
                   shouldPurchasePromoProduct product: SKProduct,
                   defermentBlock makeDeferredPurchase: @escaping RCDeferredPromotionalPurchaseBlock) {
        promoPurchaseObservers.forEach { $0()?.action((product, makeDeferredPurchase)) }
    }
}
