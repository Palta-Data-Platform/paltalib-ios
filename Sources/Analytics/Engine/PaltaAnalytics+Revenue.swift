import Amplitude

extension PaltaAnalytics {

    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(_ productIdentifier: String? = nil, quantity: Int = 1, price: NSNumber, receipt: Data? = nil) {
        amplitudeInstances.forEach {
            $0.logRevenue(productIdentifier, quantity: quantity, price: price, receipt: receipt)
        }

        // TODO
    }

    public func logRevenueV2(_ revenue: AMPRevenue) {
        amplitudeInstances.forEach {
            $0.logRevenueV2(revenue)
        }

        // TODO
    }
    
    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(amount: NSNumber) {
        amplitudeInstances.forEach {
            $0.logRevenue(amount)
        }

        // TODO
    }
    
    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(productIdentifier: String,
                           quantity: Int,
                           price: NSNumber) {
        amplitudeInstances.forEach {
            $0.logRevenue(productIdentifier,
                          quantity: quantity,
                          price: price)
        }

        // TODO
    }
    
    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(productIdentifier: String,
                           quantity: Int,
                           price: NSNumber,
                           receipt: Data) {
        amplitudeInstances.forEach {
            $0.logRevenue(productIdentifier,
                          quantity: quantity,
                          price: price,
                          receipt: receipt)
        }

        // TODO
    }

}
