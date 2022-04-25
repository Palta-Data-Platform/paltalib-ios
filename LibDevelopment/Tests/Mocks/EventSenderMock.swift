//
//  EventSenderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class EventSenderMock: EventSender {
    var sentEvents: [Event]?
    var sentTelemetry: Telemetry?
    var result: Result<(), EventSendError>?

    func sendEvents(_ events: [Event], telemetry: Telemetry?, completion: @escaping (Result<(), EventSendError>) -> Void) {
        sentTelemetry = telemetry
        sentEvents = events
        result.map(completion)
    }
}
