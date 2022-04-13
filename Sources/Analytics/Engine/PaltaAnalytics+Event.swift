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

        paltaQueues.forEach {
            $0.logEvent(
                eventType: eventType,
                eventProperties: eventProperties as? [String: Any] ?? [:],
                groups: groups as? [String: Any] ?? [:],
                timestamp: timestamp?.intValue
            )
        }
    }
    
    public func logEvent(eventType: String) {
        amplitudeInstances.forEach {
            $0.logEvent(eventType)
        }

        paltaQueues.forEach {
            $0.logEvent(eventType: eventType, eventProperties: [:], groups: [:], timestamp: nil)
        }
    }
    
    public func logEvent(eventType: String, withEventProperties eventProperties: Dictionary<String, Any>) {
        amplitudeInstances.forEach {
            $0.logEvent(eventType, withEventProperties: eventProperties)
        }

        paltaQueues.forEach {
            $0.logEvent(eventType: eventType, eventProperties:  eventProperties, groups: [:], timestamp: nil)
        }
    }
    
    public func logEvent(eventType: String,
                         withEventProperties eventProperties: Dictionary<String, Any>,
                         outOfSession: Bool) {
        amplitudeInstances.forEach {
            $0.logEvent(eventType,
                        withEventProperties: eventProperties,
                        outOfSession: outOfSession)
        }

        // TODO
    }
    
    public func logEvent(eventType: String,
                         withEventProperties eventProperties: Dictionary<String, Any>,
                         withGroups groups: Dictionary<String, Any>) {
        amplitudeInstances.forEach {
            $0.logEvent(eventType,
                        withEventProperties: eventProperties,
                        withGroups: groups)
        }

        paltaQueues.forEach {
            $0.logEvent(
                eventType: eventType,
                eventProperties: eventProperties,
                groups: groups,
                timestamp: nil
            )
        }
    }
    
    public func logEvent(eventType: String,
                         withEventProperties eventProperties: Dictionary<String, Any>,
                         withGroups groups: Dictionary<String, Any>,
                         outOfSession: Bool) {
        amplitudeInstances.forEach {
            $0.logEvent(eventType,
                        withEventProperties: eventProperties,
                        withGroups: groups,
                        outOfSession: outOfSession)
        }

        // TODO
    }

    public func logEvent(eventType: String,
                         withEventProperties eventProperties: Dictionary<String, Any>,
                         withGroups groups: Dictionary<String, Any>,
                         withLongLongTimestamp longLongTimestamp: Int64,
                         outOfSession: Bool) {
        amplitudeInstances.forEach {
            $0.logEvent(eventType,
                        withEventProperties: eventProperties,
                        withGroups: groups,
                        withLongLongTimestamp: longLongTimestamp,
                        outOfSession: outOfSession)
        }

        // TODO
    }
    
    
    public func logEvent(eventType: String,
                         withEventProperties eventProperties: Dictionary<String, Any>,
                         withGroups groups: Dictionary<String, Any>,
                         withTimestamp timestamp: NSNumber,
                         outOfSession: Bool) {
        amplitudeInstances.forEach {
            $0.logEvent(eventType,
                        withEventProperties: eventProperties,
                        withGroups: groups,
                        withTimestamp: timestamp,
                        outOfSession: outOfSession)
        }

        // TODO
    }

}
