//
//  EventComposer.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation

protocol EventComposer {
    func composeEvent(
        eventType: String,
        eventProperties: [String: Any],
        groups: [String: Any],
        timestamp: Int?
    ) -> Event
}
