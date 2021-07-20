import Amplitude

extension PaltaLib {

    public struct Event {

        fileprivate let name: String
        fileprivate let properties: [AnyHashable: Any]
        fileprivate let groups: [AnyHashable: Any]?
        fileprivate let outOfSession: Bool

        public init(name: String,
                    properties: [AnyHashable: Any] = [:],
                    groups: [AnyHashable: Any]? = nil,
                    outOfSession: Bool = false) {
            self.name = name
            self.properties = properties
            self.groups = groups
            self.outOfSession = outOfSession
        }
    }

    public func log(_ event: Event) {

    }
}
