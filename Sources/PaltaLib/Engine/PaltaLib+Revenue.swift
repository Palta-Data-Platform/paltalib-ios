import Amplitude

extension PaltaLib {

    public struct RevenueEvent {

        fileprivate let id: String
        fileprivate let price: Decimal
        fileprivate let quantity: Int
        fileprivate let type: String?
        fileprivate let receipt: Data?
        fileprivate let properties: [AnyHashable: Any]?

        public init(id: String,
                    price: Decimal,
                    quantity: Int = 1,
                    type: String? = nil,
                    receipt: Data? = nil,
                    properties: [AnyHashable: Any]? = nil) {
            self.id = id
            self.price = price
            self.quantity = quantity
            self.type = type
            self.receipt = receipt
            self.properties = properties
        }
    }

    public func logRevenue(from id: String,
                           price: Decimal) {
        logRevenue(
            .init(
                id: id,
                price: price
            )
        )
    }

    public func logRevenue(_ revenueEvent: RevenueEvent) {
        let revenue = AMPRevenue()
        revenue.setProductIdentifier(revenueEvent.id)
        revenue.setPrice(revenueEvent.price as NSNumber)
        revenue.setQuantity(revenueEvent.quantity)
        revenue.setRevenueType(revenueEvent.type)
        revenue.setReceipt(revenueEvent.receipt)
        revenue.setEventProperties(revenueEvent.properties)

        amplitureInstances.forEach {
            $0.logRevenueV2(revenue)
        }
    }
}
