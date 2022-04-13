//
//  RevenueLogger.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 13.04.2022.
//

import Foundation
import Amplitude

final class RevenueLogger {
    private let eventQueue: EventQueue
    
    init(eventQueue: EventQueue) {
        self.eventQueue = eventQueue
    }

    func logRevenue(_ productIdentifier: String?, quantity: Int, price: NSNumber, receipt: Data?) {
        let apiProperties: [String: Any] = [
            "special": kAMPRevenueEvent,
            "productId": productIdentifier as Any?,
            "quantity": quantity,
            "price": price,
            "receipt": receipt?.base64EncodedString(options: []) as Any?
        ].compactMapValues { $0 }

        eventQueue.logEvent(
            eventType: kAMPRevenueEvent,
            eventProperties: [:],
            apiProperties: apiProperties,
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )
    }

    func logRevenueV2(_ revenue: AMPRevenue) {
        guard revenue.isValidRevenue() else {
            return
        }

        guard let eventProperties = revenue.toNSDictionary() as? [String: Any] else {
            assertionFailure()
            return
        }

        eventQueue.logEvent(
            eventType: kAMPRevenueEvent,
            eventProperties: eventProperties,
            apiProperties: [:],
            groups: [:],
            userProperties: [:],
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )
    }
}
