import Amplitude

extension PaltaLib {

    public struct Event {

        fileprivate let name: String
        fileprivate let properties: [AnyHashable: Any]?
        fileprivate let groups: [AnyHashable: Any]?
        fileprivate let outOfSession: Bool

        public init(name: String,
                    properties: [AnyHashable: Any]? = nil,
                    groups: [AnyHashable: Any]? = nil,
                    outOfSession: Bool = false) {
            self.name = name
            self.properties = properties
            self.groups = groups
            self.outOfSession = outOfSession
        }
    }

    public func logEvent(_ eventType: String,
                         withEventProperties: [AnyHashable : Any]? = nil,
                         withGroups: [AnyHashable : Any]? = nil,
                         outOfSession: Bool = false) {
        logEvent(.init(name: eventType,
                       properties: withEventProperties,
                       groups: withGroups,
                       outOfSession: outOfSession))
    }

    public func logEvent(_ event: Event) {
        amplitureInstances.forEach {
            $0.logEvent(
                event.name,
                withEventProperties: event.properties,
                withGroups: event.groups,
                outOfSession: event.outOfSession
            )
        }
    }
}
