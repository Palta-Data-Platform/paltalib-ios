import Amplitude

extension PaltaAnalytics {

    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(_ productIdentifier: String? = nil, quantity: Int = 1, price: NSNumber, receipt: Data? = nil) {
        amplitudeInstances.forEach {
            $0.logRevenue(productIdentifier, quantity: quantity, price: price, receipt: receipt)
        }

        paltaQueueAssemblies.forEach {
            $0.revenueLogger.logRevenue(productIdentifier, quantity: quantity, price: price, receipt: receipt)
        }
    }

    public func logRevenueV2(_ revenue: AMPRevenue) {
        amplitudeInstances.forEach {
            $0.logRevenueV2(revenue)
        }

        paltaQueueAssemblies.forEach {
            $0.revenueLogger.logRevenueV2(revenue)
        }
    }
    
    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(amount: NSNumber) {
        logRevenue(price: amount)
    }
    
    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(productIdentifier: String,
                           quantity: Int,
                           price: NSNumber) {
        logRevenue(productIdentifier, quantity: quantity, price: price)
    }
    
    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(productIdentifier: String,
                           quantity: Int,
                           price: NSNumber,
                           receipt: Data) {
        logRevenue(productIdentifier, quantity: quantity, price: price, receipt: receipt)
    }

}
