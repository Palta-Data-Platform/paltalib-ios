//  

import Foundation
import PaltaAnlyticsTransport
import PaltaLibAnalytics

public struct EventHeader: PaltaLibAnalytics.EventHeader {
    public var parent: Parent

    internal var message: PaltaAnlyticsTransport.EventHeader {
        get {
            PaltaAnlyticsTransport.EventHeader.with {
                $0.parent = parent.message
            }
        }
    } 

    public init() {
        parent = Parent()
    }

    public init(data: Data) throws {
        let proto = try PaltaAnlyticsTransport.EventHeader(serializedData: data)
        parent = Parent(message: proto.parent)
    }

    public func serialize() throws -> Data {
        try message.serializedData()
    }
}

extension EventHeader {
    public struct Parent {
        internal var message: EventHeaderParent

        public init(message: EventHeaderParent) {
            self.message = message
        }

        public init(parentElements: [String] = []) {
            message = .init()
            message.parentElements = parentElements.map { $0 }
        }
    }
}
