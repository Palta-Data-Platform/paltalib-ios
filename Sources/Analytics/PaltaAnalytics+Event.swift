import Amplitude

extension PaltaAnalytics {

    public func logEvent(_ eventType: String,
                         withEventProperties eventProperties: [AnyHashable : Any]? = nil,
                         withGroups groups: [AnyHashable : Any]? = nil,
                         withTimestamp timestamp: NSNumber? = nil,
                         outOfSession: Bool = false) {

        if let timestamp = timestamp {
            amplitudeInstances.forEach {
                $0.logEvent(
                    eventType,
                    withEventProperties: eventProperties,
                    withGroups: groups,
                    withTimestamp: timestamp,
                    outOfSession: outOfSession
                )
            }
        } else {
            amplitudeInstances.forEach {
                $0.logEvent(
                    eventType,
                    withEventProperties: eventProperties,
                    withGroups: groups,
                    outOfSession: outOfSession
                )
            }
        }
    }
}
