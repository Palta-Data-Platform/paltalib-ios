//
//  RestoreRequestData.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 06.04.2022.
//

import Foundation

struct RestoreRequestData: Encodable {
    enum CodingKeys: String, CodingKey {
        case email
        case webSubscriptionID = "web_subscription_id"
    }

    let email: String
    let webSubscriptionID: String
}
