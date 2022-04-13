//
//  IdentityLogger.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 13.04.2022.
//

import Foundation
import Amplitude

final class IdentityLogger {
    private let identifyEventType = "$identify"
    private let groupIdentifyEventType = "$groupidentify"

    private let eventQueue: EventQueue

    init(eventQueue: EventQueue) {
        self.eventQueue = eventQueue
    }

    func identify(
        _ identify: AMPIdentify,
        outOfSession: Bool = false
    ) {
        guard let userProperties = identify.userPropertyOperations as? [String: Any] else {
            assertionFailure()
            return
        }

        eventQueue.logEvent(
            eventType: identifyEventType,
            eventProperties: [:],
            apiProperties: [:],
            groups: [:],
            userProperties: userProperties,
            groupProperties: [:],
            timestamp: nil,
            outOfSession: outOfSession
        )
    }

    func groupIdentify(
        groupType: String,
        groupName: NSObject,
        groupIdentify: AMPIdentify,
        outOfSession: Bool
    ) {
        guard
            let groupProperties = groupIdentify.userPropertyOperations as? [String: Any],
            !groupType.isEmpty
        else {
            assertionFailure()
            return
        }

        eventQueue.logEvent(
            eventType: groupIdentifyEventType,
            eventProperties: [:],
            apiProperties: [:],
            groups: [groupType: groupName],
            userProperties: [:],
            groupProperties: groupProperties,
            timestamp: nil,
            outOfSession: outOfSession
        )
    }

    func setUserProperties(_ userProperties: [String: Any]) {
        let identifyObject = AMPIdentify()

        userProperties.forEach {
            identifyObject.set($0.key, value: $0.value as? NSObject)
        }

        identify(identifyObject)
    }

    func clearUserProperties() {
        identify(AMPIdentify().clearAll())
    }

    func setGroup(groupType: String, groupName: NSObject) {
        guard
            let userProperties = AMPIdentify().set(groupType, value: groupName).userPropertyOperations as? [String: Any]
        else {
            assertionFailure()
            return
        }

        eventQueue.logEvent(
            eventType: identifyEventType,
            eventProperties: [:],
            apiProperties: [:],
            groups: [groupType: groupName],
            userProperties: userProperties,
            groupProperties: [:],
            timestamp: nil,
            outOfSession: false
        )
    }
}
