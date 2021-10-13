import Foundation
import Purchases

public struct PurchaseEntitlement {
    public enum Source {
        case native, web
    }

    public enum Period {
        case normal, introductory, trial
    }

    public let name: String
    public let isActive: Bool
    public let source: Source
    public let periodType: Period
    public let willRenew: Bool
    public let expirationDate: Date?
}

public protocol PurchaserInfo {
    var entitlements: [PurchaseEntitlement] { get }
    var activeSubscriptions: [String] { get }
    var allPurchasedProductIdentifiers: [String] { get }
}

extension PurchaserInfo {
    public func isEntitlementNamePurchased(_ entitlementName: String) -> Bool {
        return entitlements
            .filter { $0.isActive }
            .map { $0.name }
            .contains(entitlementName)
    }
}

struct PurchaserInfoRCAdapter: PurchaserInfo {
    let info: Purchases.PurchaserInfo

    var entitlements: [PurchaseEntitlement] {
        return info.entitlements.all.map {
            PurchaseEntitlement(name: $0.key,
                                isActive: $0.value.isActive,
                                source: $0.value.store == .appStore ? .native : .web,
                                periodType: $0.value.periodType.period,
                                willRenew: $0.value.willRenew,
                                expirationDate: $0.value.expirationDate)
        }
    }

    var activeSubscriptions: [String] {
        return Array(info.activeSubscriptions)
    }

    var allPurchasedProductIdentifiers: [String] {
        return Array(info.allPurchasedProductIdentifiers)
    }
}

extension Purchases.Offering {
    var productsByPackageID: [String: SKProduct] {
        return availablePackages.reduce(into: [String: SKProduct]()) {
            $0[$1.identifier] = $1.product
        }
    }
}

private extension Purchases.PeriodType {
    var period: PurchaseEntitlement.Period {
        switch self {
        case .normal: return .normal
        case .intro: return .introductory
        case .trial: return .trial
        default: return .normal
        }
    }
}
