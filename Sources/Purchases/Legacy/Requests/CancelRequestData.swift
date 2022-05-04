//
//  CancelRequestData.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation

struct CancelRequestData: Encodable {
    enum CodingKeys: String, CodingKey {
        case revenueCatID = "revenue_cat_id"
        case webSubscriptionID = "web_subscription_id"
    }

    let revenueCatID: String
    let webSubscriptionID: String
}
