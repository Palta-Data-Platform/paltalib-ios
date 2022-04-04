//
//  EventSenderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation

final class EventSenderMock: EventSender {
    var sentEvents: [Event]?
    var result: Result<(), EventSendError>?

    func sendEvents(_ events: [Event], completion: @escaping (Result<(), EventSendError>) -> Void) {
        sentEvents = events
        result.map(completion)
    }
}
