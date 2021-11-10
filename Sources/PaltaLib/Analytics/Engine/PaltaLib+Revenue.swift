import Amplitude

extension PaltaLib {

    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(_ productIdentifier: String? = nil, quantity: Int = 1, price: NSNumber, receipt: Data? = nil) {
        amplitudeInstances.forEach {
            $0.logRevenue(productIdentifier, quantity: quantity, price: price, receipt: receipt)
        }
    }

    public func logRevenueV2(_ revenue: AMPRevenue) {
        amplitudeInstances.forEach {
            $0.logRevenueV2(revenue)
        }
    }
    
    @available(*, deprecated, message: "Use `logRevenueV2` and `AMPRevenue` instead")
    public func logRevenue(amount: NSNumber) {
        amplitudeInstances.forEach {
            $0.logRevenue(amount)
        }
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
    }

}
